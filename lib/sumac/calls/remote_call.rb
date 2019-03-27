module Sumac
  class Calls

    # Represents a call originating from the remote endpoint.
    # @api private
    class RemoteCall

      # Build a new {RemoteCall}.
      # @param connection [Connection] call is to be made on
      # @return [RemoteCall]
      def initialize(connection)
        @connection = connection
        @id = nil
        @object_reference = nil
        @object = nil
        @method = nil
        @arguments_references = nil
        @arguments = nil
        @return_error = nil
        @return_value = nil
      end

      # Returns the id of the call.
      # @return [Integer]
      attr_reader :id

      # Validate the received properties for the call, make the call, and return a response.
      # @param message [Messages::CallRequest]
      # @raise [ProtocolError] if part of the message is not valid
      # @return [void]
      def process_request_message(message)
        parse_message(message)
        # if the request is not valid we must remember to free any references we just built to avoid a memory leak
        Thread.new do
          build_objects
          if @connection.object_request_broker.validate_request(self)
            process_call
            @connection.object_request_broker.respond(self)
          end
        end
      end

      # Send response message.
      # @return [void]
      def process_response
        unless @return_error
          begin
            @connection.objects.ensure_sendable(@return_value)
          rescue StandardError => error
            @return_error = error
          end
        end
        if @return_error
          respond_with_error(@return_error)
        else
          respond_with_value(@return_value)
        end
      end

      # Validate the received method and arguments for the call.
      # @return [Boolean] if request is valid (a response has not been sent)
      def validate_request
        binding.pry if $debug
        rejected_error = validate_method || validate_arguments
        if rejected_error
          reject
          #if public mode
            #kill
          #else
            respond_with_rejected_error(rejected_error)
          #end
          return false
        end
        accept
        true
      end

      private

      # Accept the call request.
      # To be called if the call is to be started.
      # The argument's references will be settled.
      # @return [void]
      def accept
        @arguments_references.each { |argument_reference| @connection.objects.accept_reference(argument_reference) }
      end

      # Determine the acceptable number of arguments the method will accept.
      # @return [Range<Integer,Float>]
      def acceptable_argument_count
        parameters = @object.method(@method).parameters
        min_args = parameters.select{ |arg| arg[0] == :req }.count
        if parameters.any? { |arg| arg[0] == :rest }
          max_args = Float::INFINITY
        else
          max_args = parameters.count
        end
        (min_args..max_args)
      end

      # Build the object can arguments that will be used for this call.
      # @return [void]
      def build_objects
        @object = @connection.objects.convert_reference_to_object(@object_reference)
        @arguments = @arguments_references.map { |arguments_reference| @connection.objects.convert_reference_to_object(arguments_reference) }
      end

      # Parse the received properties for the call.
      # @param message [Messages::CallRequest]
      # @raise [ProtocolError] if a local reference does not exist with received id
      # @return [void]
      def parse_message(message)
        @id = message.id
        @object_reference = @connection.objects.convert_properties_to_reference(message.object, build: false)
        @method = message.method
        @arguments_references = message.arguments.map { |argument_properties| @connection.objects.convert_properties_to_reference(argument_properties, tentative: true) }
      end

      # Make the call.
      # @return [void]
      def process_call
        begin
          @return_value = @object.__send__(@method, *@arguments)
        rescue StandardError => error
          @return_error = error
        end
      end

      # Reject the call request.
      # To be called if the call could not be started.
      # The argument's references will be forgotten unless they are in use elsewhere.
      # @return [void]
      def reject
        @arguments_references.each { |argument_reference| @connection.objects.reject_reference(argument_reference) }
      end

      # Build and send response message for an error.
      # @return [void]
      def respond_with_error(error)
        response = Messages::CallResponse.build(id: @id, exception: error)
        @connection.messenger.send(response)
      end

      # Build and send response message for a rejected call.
      # @return [void]
      def respond_with_rejected_error(error)
        response = Messages::CallResponse.build(id: @id, rejected_exception: error)
        @connection.messenger.send(response)
      end

      # Build and send response message for a value.
      # @return [void]
      def respond_with_value(value)
        return_value_properties = @connection.objects.convert_object_to_properties(value)
        response = Messages::CallResponse.build(id: @id, return_value: return_value_properties)
        @connection.messenger.send(response)
      end

      # Validate arguments.
      # Generate an {ArgumentError} with relevant message when given argument count is invalid.
      # @return [nil,ArgumentError]
      def validate_arguments
        # TODO: add support for blocks
        #    sample [[:req, :bar], [:opt, :baz], [:rest, :args], [:block, :blk]]
        #min_args = parameters.select{ |arg| arg[0].one_of?(:req, :block) }.count
        acceptable_range = acceptable_argument_count
        unless acceptable_range.include?(@arguments.count)
          if acceptable_range.size == 1
            expected_string = "#{acceptable_range.first}"
          elsif acceptable_range.last.infinite?
            expected_string = "#{acceptable_range.first}+"
          else
            expected_string = "#{acceptable_range}"
          end
          error_message = "wrong number of arguments (given #{@arguments.count}, expected #{expected_string})"
          error = ArgumentError.new(error_message)
        end
      end

      # Validate that method is exposed (exists and safe to call).
      # Generate an {UnexposedMethodError} when method is not available.
      # @return [nil,UnexposedMethodError]
      def validate_method
        UnexposedMethodError.new unless @connection.objects.exposed_method?(@object, @method)
      end

    end

  end
end
