class VMCoordinator
  def initialize(args = {})
    @chef = args[:chef]
    @redis = args[:redis]
    @role = args[:role]
    @redis_key = 'service' + args[:service_id] if args[:service_id]
  end

  def run_chef(args)
    check_run_preconditions(args)
    @chef.run(args)
  end

  def execute_db_operation
    yield @redis_key, @redis
  end


  private

  def check_run_preconditions(args)
    raise ArgumentError if args.nil? or args.empty?
    node_object = args[:node_object]
    raise ArgumentError if node_object.nil? or node_object.empty?
  end

end