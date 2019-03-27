class Object
  
  # Check if +self+ is +==+ to one of the arguments.
  # @param args [Array<Object>]
  # @return [Boolean]
  def one_of?(*args)
    args.include?(self)
  end

end
