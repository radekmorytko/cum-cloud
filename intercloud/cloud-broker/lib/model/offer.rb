module Intercloud

  class InvalidOfferTimeRange < StandardError
  end

  class Offer
    include DataMapper::Resource

    property :id, Serial

    property :controller_id, String # and its routing key as well
    property :received_at,   DateTime, :default => DateTime.now

    property :cpu_specification, Json

    belongs_to :service_specification

    def total_cost # a day

    end

    def cpu_cost # a day
      # check hours
      hours = cpu_specification[:schedule].reduce(0) { |sum, cpu_spec| sum + (cpu_spec[:time_span][:to] == '00' ? '24' : cpu_spec[:time_span][:to]).to_i - cpu_spec[:time_span][:from].to_i }
      raise InvalidOfferTimeRange unless hours == 24

      cpu_specification[:schedule].reduce(0) do |cost, cpu_spec|
        hours = (cpu_spec[:time_span][:to] == '00' ? '24' : cpu_spec[:time_span][:to]).to_i - cpu_spec[:time_span][:from].to_i
        cost + cpu_spec[:price] * hours
      end
    end

  end
end