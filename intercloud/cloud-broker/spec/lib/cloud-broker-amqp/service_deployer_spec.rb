require 'spec_helper'
require 'cloud-broker-amqp/service_deployer'
require 'resource-mapping/offer_selector'

describe ServiceDeployer do
  let(:publisher) { double('Publisher', :publish => true) }
  subject { ServiceDeployer.new(OfferSelector.new, publisher) }
  
  before do
    @service_specification = ss = ServiceSpecification.create(
      :name => 'weszlo.com',
      :client_endpoint => '192.168.0.166'
    )
    ss.stacks.create({:type => 'java', :instances => 3})
    ss.stacks.create({:type => 'ruby', :instances => 1})
    ss.stacks.create({:type => 'postgres', :instances => 2})
    date = DateTime.new(2013, 11, 18, 13, 20, 56) 
    cost_hash = {
      'java' => {
        'c1' => 101,
        'c2' => 102,
        'c3' => 103
      },
      'ruby' => {
        'c1' => 103,
        'c2' => 101,
        'c3' => 102
      },
      'postgres' => {
        'c1' => 103,
        'c2' => 102,
        'c3' => 101
      }
    }
    %w(java ruby postgres).each do |type|
      stack = ss.stacks(:type => type).first
      %w(c1 c2 c3).each do |cloud_id|
        stack.offers.create({:cost => cost_hash[type][cloud_id], :controller_id => cloud_id, :received_at => date})
      end
    end
  end
  describe 'when there are candidates for deployment' do
    it 'deploys them' do
      publisher.should_receive(:publish).exactly(3).times
      subject.deploy_services
    end
  end

end
