module Intercloud
  class MessageProcessor
    def initialize(schedule_queue, config)
      @config          = config
      @schedule_queue  = schedule_queue
    end

    def run
      EM.run do
        AMQP.connect('amqp://' + @config['amqp']['host'] + ':' + @config['amqp']['port'].to_s) do |connection|
          channel = AMQP::Channel.new(connection)

          offers_exchange = channel.fanout(@config['amqp']['offers_exchange_name'])

          # Getting offers from clouds
          channel.queue(@config['amqp']['offers_routing_key']).subscribe do |metadata, payload|
            puts "Got an offer! #{metadata.type} and payload: #{payload}"
            message = JSON.parse(payload)

            puts 'Adding the offer to db'
            # add the offer to the DB
            service_specification = ServiceSpecification.get(message['id'])
            service_specification.offers.create(
                :controller_id => message['controller_routing_key'],
                :price         => message['offer']['price'],
                :memory        => message['offer']['memory']
            )
            service_specification.save
            service_specification.offers.reload
          end


          # Publishing offers to clouds
          EM.add_periodic_timer(1) do
            while not @schedule_queue.empty?
              puts 'sending a message: ' + (msg = @schedule_queue.pop).to_s
              offers_exchange.publish(msg)
            end
          end

          # select services to deploy
          EM.add_periodic_timer(5) do
            p 'Checking for services to deploy'
            ServiceSpecification.all(:deployed => false, :broker_id => @config['broker_id']).each do |service|

              # I did not figure it out yet, but this is done deliberately
              # Otherwise offers are not retrieved :/
              service = ServiceSpecification.get(service.id)

              next if service.offers.count == 0

              latest_offer = service.offers.max_by { |o| o.received_at }

              #if the last offer was received more than X seconds ago - choose the appropriate offer and deploy
              #threshold value is 10 seconds
              if (DateTime.now - latest_offer.received_at).to_f * 24 * 60 * 60 > 10
                p "Choosing among the offers for a service (id: #{service.id})"

                # TODO create the real mechanism for selection
                chosen_offer = service.offers.choice

                p "Chosen offer: #{chosen_offer}"

                # notify the cloud
                channel.default_exchange.publish("I'm accepting your offer", :routing_key => chosen_offer.controller_id)

                # mark as deployed
                service.deployed = true
                service.save
              end
            end
          end

          Signal.trap('INT') {
            puts 'Closing AMQP connection'
            connection.close {
              EM.stop
            }
          }
        end
      end

    end
  end
end