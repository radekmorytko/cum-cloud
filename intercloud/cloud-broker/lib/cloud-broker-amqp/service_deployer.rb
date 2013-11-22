require 'common/configurable'

class ServiceDeployer
  include Configurable

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(offer_matcher, publisher)
    @offer_matcher = offer_matcher
    @publisher     = publisher
  end

  def deploy_services
    deploy_candidates.each { |s| deploy_service(s) }
  end

  private
  # precondition: there is at least one offer for the given service
  def deploy_service(service)
    selected_offer = @offer_matcher.match(service, service.offers.map { |o| o })
    @@logger.info("#{selected_offer} is the selected offer for #{service}")
    deployment_msg = prepare_deployment_message(service, selected_offer)
    @@logger.debug("Notifying the cloud controller: #{selected_offer.controller_id}")
    @@logger.debug("Deployment message: #{deployment_msg}")
    service.deployed = true
    service.save
    @publisher.publish(deployment_msg,
                       :routing_key => selected_offer.controller_id
                      )
  end 

  def deploy_candidates
    ServiceSpecification.all(:deployed => false, :broker_id => config['broker_id'])
                        .select { |ss| ss.ready_to_deploy? }
  end

  def prepare_deployment_message(service, chosen_offer)
    service.specification
  end
end

