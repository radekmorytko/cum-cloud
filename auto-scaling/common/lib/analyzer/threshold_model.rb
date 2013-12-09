module AutoScaling
  class ThresholdModel

    @@logger = Logger.new(STDOUT)

    def initialize(arguments)
      @min = arguments['min'].to_i
      @max = arguments['max'].to_i

      raise ArgumentError, "min: #{@min} has to be lesser or equal than max: #{@max}" if @min > @max
    end

    # Analyzes data using threshold model
    #
    # * *Args* :
    # - +data+ -> list of data, ex: ["10", "243", "432"]
    #
    # Return decision whether supplied data fits / is lesser / is greater than range [@min, @max]
    def analyze(data)
      # wrap data if it is not an array (ie single value, aggregated beforehand)
      data = [data] unless data.kind_of?(Array)

      @@logger.debug "Using threshold model (#{@min}, #{@max}) to analyze data: #{data}"

      lesser = data.count {|value| value.to_i < @min }
      greater = data.count {|value| value.to_i > @max }

      return :fits if lesser == 0 and greater == 0
      return :lesser if lesser >= greater
      return :greater if greater > lesser

      raise RuntimeError, "Supplied data (#{data}) cannot be matched against model #{@min} / #{@max}"
    end

  end
end
