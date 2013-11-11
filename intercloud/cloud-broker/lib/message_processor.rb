module Intercloud
  class MessageProcessor
    def initialize(schedule_queue, config)
      @config          = config
      @schedule_queue  = schedule_queue
      @offers_matcher  = initialize_offers_matcher
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
                :cpu_specification => message['offer']['cpu_specification']
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
                chosen_offer = @offers_matcher.match(service, service.offers)

                p "Chosen offer: #{chosen_offer}"

                if chosen_offer.nil?
                  p "There is no appropriate offer for the service requirements"
                  next
                end

                # notify the cloud
                attrs = service.attributes
                msg = [:stack, :instances, :name].reduce({}) { |acc, e| acc[e] = attrs[e]; acc }
                channel.default_exchange.publish(msg.to_json, :routing_key => chosen_offer.controller_id)

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

    private

    def initialize_offers_matcher
      class_name        = prepare_offers_match_classname(@config['offers_matching']['strategy'])
      matching_startegy = Intercloud::const_get(class_name).new
      OffersMatcher.new(matching_startegy)
    end

    def prepare_offers_match_classname(offers_matching_strategy)
      offers_matching_strategy.capitalize + 'Strategy'
    end
  end
end