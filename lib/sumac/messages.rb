module Sumac

  # Namespace for a collection of classes representing Sumac messages and message components.
  # @note Building an outgoing message must never raise an error, as to avoid ending up in an unknown state.
  #   For example, imagine building a call request where the first method's argument is a {LocalObject} that
  #   has never been sent and the second is an unexposed object. The problem is, a reference will be built
  #   for the first argument but the message will not get sent due to an error being raised for the second.
  #   Now we have a reference that will need to be forgoten that the local endpoint may not even know about.
  #   For long long lived connections this memory leak may be significant. For this reason all checks must
  #   be done before building the outgoing message.
  # @api private
  module Messages

    # Parse a received json string into a {Messages::Message}.
    # @param message_string [String]
    # @raise [ProtocolError] if json can not be parsed into a valid Sumac message
    # @return [Messages::Message]
    def self.from_json(message_string)
      begin
        properties = JSON.parse(message_string, allow_nan: true, max_nesting: Message.max_json_nesting_depth)
      rescue JSON::ParserError
        raise ProtocolError
      end
      from_properties(properties)
    end

    # Parse a received json object into a {Messages::Message}.
    # @param properties [Hash] json object
    # @raise [ProtocolError] if json object can not be parsed into a valid Suamc message
    # @return [Messages::Message]
    def self.from_properties(properties)
      raise ProtocolError unless properties.is_a?(Hash)
      message = get_class(properties['message_type']).from_properties(properties)
    end

    # Find the correct {Messages::Message} for the +'message_type'+ property.
    # @param message_type [String]
    # @raise [ProtocolError] if no valid {Messages::Message} is found.
    # @return [Class]
    def self.get_class(message_type)
      case message_type
      when 'call_request' then CallRequest
      when 'call_response' then CallResponse
      when 'compatibility' then Compatibility
      when 'forget' then Forget
      when 'initialization' then Initialization
      when 'shutdown' then Shutdown
      else raise ProtocolError
      end
    end

  end

end
