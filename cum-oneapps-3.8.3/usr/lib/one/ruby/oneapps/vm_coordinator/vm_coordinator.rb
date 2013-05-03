class VMCoordinator
  def initialize(args = {})
    @chef = args[:chef]
  end

  def run_chef(args)
    check_run_preconditions(args)
    @chef.run(args)
  end


  private

  def check_run_preconditions(args)
    raise ArgumentError if args.nil? or args.empty?
    node_object = args[:node_object]
    raise ArgumentError if node_object.nil? or node_object.empty?
  end

end