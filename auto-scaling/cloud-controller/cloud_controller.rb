require 'rubygems'
require 'logger'

module AutoScaling

  class CloudController
    @@logger = Logger.new(STDOUT)

    # Handle request passed from lower layer (service-controller)
    #
    # * *Args* :
    # - +conclusion+ -> an action that lower layer wanted to perform
    # - +stack+ -> subject of above-mentioned action
    def forward(conclusion, stack)
      @@logger.info "Received request of #{conclusion} to be performed on #{stack}"
    end

    def self.build
      CloudController.new
    end

  end

end
