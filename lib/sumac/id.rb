module Sumac

  # Methods to help work with ids.
  # All calls and object references have an id.
  # A valid id is a non negative Integer.
  # @api private
  module ID

    # Check if an object is a valid id.
    # @param object [Object]
    # @return [Boolean]
    def self.valid?(object)
      object.is_a?(Integer) && object >= 0
    end

  end

end
