require 'rubygems'
require 'logger'

module AutoScaling

  class CloudController
    @@logger = Logger.new(STDOUT)

    @@instances_cnt = 0

    # Handle request passed from lower layer (service-controller)
    #
    # * *Args* :
    # - +conclusion+ -> an action that lower layer wanted to perform
    # - +stack+ -> subject of above-mentioned action
    def forward(conclusion, stack)
      @@logger.info "Received request of #{conclusion} to be performed on #{stack}"
    end

    def self.build
      if @@instances_cnt == 1
        raise 'There can be only one instance of CloudController'
      end
      @@instances_cnt += 1
      CloudController.new
      Thread.start do
        require 'lib/message_processor'
      end
    end

  end

end
