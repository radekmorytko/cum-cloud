require 'spec_helper'
require 'cloud-broker-amqp/service_deployer'
require 'resource-mapping/offer_selector'
require 'securerandom'

describe ServiceDeployer do
  let(:publisher) { double('Publisher', :publish => true) }
  subject { ServiceDeployer.new(OfferSelector.new, publisher) }

  let(:service_specification) do
    ServiceSpecification.create(
      :name => "weszlo.com #{SecureRandom.urlsafe_base64(4)}",
      :client_endpoint => '192.168.0.166'
    )
  end

  let(:policy_set) { 
    {
      "min_vms"=>0,
      "max_vms"=>2,
      "policies"=>[
        {
          "name"=>"threshold_model",
          "parameters"=>{
            "min"=>"5",
            "max"=>"50"
          }
        }
      ]
    } 
  }

  before do
    ss = service_specification
    ss.stacks.create({:type => 'java', :instances => 3, :policy_set => policy_set})
    ss.stacks.create({:type => 'ruby', :instances => 1, :policy_set => policy_set})
    ss.stacks.create({:type => 'postgres', :instances => 2, :policy_set => policy_set})
    ss.stacks.create({:type => 'python', :instances => 3, :policy_set => policy_set})
    ss.stacks.create({:type => 'amqp', :instances => 3, :policy_set => policy_set})
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
      },
      'python' => {
        'c1' => 120,
        'c2' => 119,
        'c3' => 118
      },
      'amqp' => {
        'c1' => 130,
        'c2' => 129,
        'c3' => 131
      }
    }
    %w(java ruby postgres python amqp).each do |type|
      stack = ss.stacks(:type => type).first
      %w(c1 c2 c3).each do |cloud_id|
        stack.offers.create({:cost => cost_hash[type][cloud_id], :controller_id => cloud_id, :received_at => date})
      end
    end
  end
  describe 'when there is an offer for autoscaling the cloud' do
    let(:type) { 'java' }
    let(:stack_under_test) { service_specification.stacks(:type => type).first }
    before do
      subject.deploy_services
      stack_under_test.update(:status => :scaling)
      stack_under_test.offers
                      .create({:cost => 10, :controller_id => 'cid', :received_at =>  DateTime.new(2013, 11, 18, 13, 20, 56) })
      stack_under_test.reload
    end
    
    it 'deployes one server' do
      publisher.should_receive(:publish).exactly(1).times
      subject.deploy_services
    end

    it 'changes the status of a deployed stack to :deployed' do
      subject.deploy_services
      expect(stack_under_test.status).to eq :deployed
    end
  end

  describe 'when there are candidates for deployment' do
    it 'deploys them by publishing messages to cloud controllers' do
      publisher.should_receive(:publish).exactly(3).times
      subject.deploy_services
    end

    it 'changes the status of a deployed stack to :deployed' do
      subject.deploy_services
      service_specification.reload
      service_specification.stacks.each do |stack|
        expect(stack.status).to eq :deployed
      end
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
