
module AutoScaling
  class ThresholdModel

    def initialize(min, max)
      raise ArgumentError, "min: #{min} has to be lesser or equal than max: #{max}" if min > max

      @min = min
      @max = max
    end

    def analyze(data)
      # wrap data if it is not an array (ie single value, aggregated beforehand)
      data = [data] unless data.kind_of?(Array)

      lesser = data.count {|value| value.to_i < @min }
      greater =  data.count {|value| value.to_i > @max }

      # todo aggregate
      return :fits if lesser == 0 and greater == 0
      return :lesser if lesser >= greater
      return :greater if greater > lesser

      raise RuntimeError, "Supplied data (#{data}) cannot be matched against model #{min} / #{max}"
    end
  end
end
