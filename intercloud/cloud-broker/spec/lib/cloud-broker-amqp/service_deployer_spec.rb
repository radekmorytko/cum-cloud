require 'spec_helper'
require 'cloud-broker-amqp/service_deployer'
require 'resource-mapping/offer_selector'

describe ServiceDeployer do
  let(:publisher) { double('Publisher', :publish => true) }
  subject { ServiceDeployer.new(OfferSelector.new, publisher) }

  let(:service_specification) do
    ServiceSpecification.create(
      :name => 'weszlo.com',
      :client_endpoint => '192.168.0.166'
    )
  end
  
  before do
    ss = service_specification
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
  describe 'when there is an offer for autoscaling the cloud' do
    before do
      subject.deploy_services
      type = 'java'
      stack = service_specification.stacks(:type => type).first
      stack.update(:status => :scaling)
      stack.offers.create({:cost => 10, :controller_id => 'cid', :received_at =>  DateTime.new(2013, 11, 18, 13, 20, 56) })
    end
    
    it 'deployes one server' do
      publisher.should_receive(:publish).exactly(1).times
      subject.deploy_services
    end
  end
  describe 'when there are candidates for deployment' do
    it 'deploys them by publishing messages to cloud controllers' do
      publisher.should_receive(:publish).exactly(3).times
      subject.deploy_services
    end


    it 'deploys them by changing the status of all offers to `examined\'' do
      subject.deploy_services
      service_specification.stacks.each do |stack|
        expect(stack.offers(:examined => true).count).to  eq 3
        expect(stack.offers(:examined => false).count).to eq 0
      end
    end
  end
end
