module Sumac
  module Messages

    # Representes a _Sumac_ message (and not a message component).
    # @api private
    class Message < Base

      # Calculates the maximum possible depth of a json data structure representing a message.
      # Uses the assigned object nesting depth to find the json depth of the deepest possible argument of a call request.
      # @return [Integer]
      def self.max_json_nesting_depth
        # to calculate the maximum possible json depth we will consider a call_request
        #   with an argument of Hashes nested MAX_OBJECT_NESTING_DEPTH deep
        # the process to calculate it is described here
        # we will want to derive an equation to get the json depth from the object depth
        # start by creating the json for a call_request with an argument nested 1 deep ({'something' => 1}):
        #   { "message_type" : "call_request", "id" : 0, "object" : "...object_properties...", "method" : "m", "arguments" : [{ "object_type" : "map", "pairs" : [ { "key" : "...key_properties...", "value" : { "object_type" : "integer", "value" : 1 } } ] }]}
        # remove the short branches to get:
        #   { "arguments" : [{ "pairs" : [ { "value" : { "value" : 1 } } ] }]}
        # we can see it has a json depth of 6
        # now try an argument nested 2 deep ({'something' => {'something' => 1}}), we should get:
        #   { "arguments" : [{ "pairs" : [ { "value" : { "pairs" : [ { "value" : { "value" : 1 } } ] } } ] }]}
        # we can see it has a json depth of 9
        # now try an argument nested 3 deep ({'something' => {'something' => {'something' => 1}}}), we should get:
        #   { "arguments" : [{ "pairs" : [ { "value" : { "pairs" : [ { "value" : { "pairs" : [ { "value" : { "value" : 1 } } ] } } ] } } ] }]}
        # we can see it has a json depth of 12
        # we find the equation to be y = 3x + 3, where x is argument depth and y is json depth
        max_json_depth = (3 * Sumac::MAX_OBJECT_NESTING_DEPTH) + 3
      end

      # Converts the message to a json string.
      # @return [String]
      def to_json
        JSON.generate(properties, allow_nan: true, max_nesting: false)
      end

    end

  end
end
