require 'common/configurable'

class ServiceDeployer
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(offer_selector, publisher)
    @offer_selector = offer_selector
    @publisher      = publisher
  end

  def deploy_services
    deploy_candidates.each { |s| deploy_service(s) }
  end

  private
  # precondition: there is at least one offer for the given service
  def deploy_service(service)
    @@logger.info("Deploying service `#{service.name}'")

    # for each stack select an appropriate offer
    selected_offers = service.stacks.select { |stack| stack.ready_to_deploy? }.map do |stack|
      @offer_selector.select(stack.offers.map { |o| o }) 
    end

    # group according to CC
    services_instances = selected_offers.reduce({}) do |memo, offer|
      memo[offer.controller_id] = [] unless memo.has_key?(offer.controller_id)
      memo[offer.controller_id] << offer.stack
      memo
    end

    @@logger.info("Service `#{service.name}' comprises #{selected_offers.count} stacks" \
                  " which are to be deployed on #{services_instances.keys.count}" \
                  " different clouds. Total cost of deployment: #{selected_offers.reduce(0){|acc, o| acc + o.cost}}")

    # for each cc, deploy an instance of the service
    services_instances.each do |cloud_id, stacks|
      deployment_msg = prepare_deployment_message(service, stacks)
      @publisher.publish(deployment_msg,
                         :routing_key => cloud_id
                        )

      # update stack and its offers attributes
      stacks.each do |stack|
        stack.status        = :deployed
        stack.controller_id = cloud_id
        stack.save

        stack.offers.update(:examined => true)
      end


      @@logger.debug("Notifying the cloud controller: #{cloud_id}")
      @@logger.debug("Deployment message: #{deployment_msg}")
    end

  end 

  def deploy_candidates
    ServiceSpecification.all
                        .select { |ss| ss.ready_to_deploy? }
  end

  def prepare_deployment_message(service, stacks)
    stacks_attributes = stacks.map do |stack|
      attributes = stack.attributes
      {
        :type       => attributes[:type],
        :instances  => attributes[:instances],
        :policy_set => attributes[:policy_set]
      }
    end
    {
      :name                   => service.name,
      :stacks                 => stacks_attributes,
      :autoscaling_queue_name => config['amqp']['autoscaling_queue_name']
    }.to_json
  end
end

