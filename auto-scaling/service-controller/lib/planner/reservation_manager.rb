require 'thread'

module AutoScaling

  class ReservationManager

    def initialize
      @reservation = Mutex.new
    end

  end
end