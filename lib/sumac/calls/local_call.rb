module Sumac
  class Calls

    # Represents a call originating from this endpoint.
    # @api private
    class LocalCall

      # Build a new {LocalCall}.
      # @param connection [Connection] call is to be made on
      # @param id [Integer] id call will get
      # @param object [RemoteObject] object being called
      # @param method [String] method being called
      # @param arguments [Array<Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String>] arguments being passed
      # @return [LocalCall]
      def initialize(connection, id: , object: , method: , arguments: )
        @connection = connection
        @id = id
        @object = object
        @object_reference = nil
        @method = method
        @arguments = arguments
        @arguments_references = nil
        @return_future = QuackConcurrency::Future.new
      end

      # Cancel this call.
      # To be called when the connection has closed and this call has not got a response yet.
      # Will remove it from the connection's list of calls and wake the thread waiting on a response with
      # a {ClosedObjectRequestBrokerError} error.
      # @return [void]
      def cancel
        @return_future.raise(ClosedObjectRequestBrokerError)
      end

      # Returns the id of the call.
      # @return [Integer]
      attr_reader :id

      # Processes a response message for this call.
      # Called when a {Messages::CallResponse} has been received by the messenger.
      # @param message [Messages::CallResponse]
      # @raise [ProtocolError] if a local reference does not exist with received id
      # @return [void]
      def process_response_message(message)
        if message.rejected_exception
          rejected
          @return_future.raise(message.rejected_exception)
        else
          accepted
          if message.exception
            @return_future.raise(message.exception)
          else
            return_value = @connection.objects.convert_properties_to_object(message.return_value)
            @return_future.set(return_value)
          end
        end
      end

      # Returns the future that will be set once the call has got a response.
      # @return [QuackConcurrency::Future]
      attr_reader :return_future

      # Sends the request message to the remote endpoint.
      # @return [void]
      def send
        parse_objects
        object_properties = @connection.objects.convert_reference_to_properties(@object_reference)
        arguments_properties = @arguments_references.map { |argument_reference| @connection.objects.convert_reference_to_properties(argument_reference) }
        message = Messages::CallRequest.build(id: @id, object: object_properties, method: @method, arguments: arguments_properties)
        @connection.messenger.send(message)
      end

      private

      # Accept the call request.
      # To be called if the call is to be started.
      # The argument's references will be settled.
      # @return [void]
      def accepted
        @arguments_references.each { |argument_reference| @connection.objects.accept_reference(argument_reference) }
      end

      # Get the object's reference and arguments' references.
      # @return [void]
      def parse_objects
        @object_reference = @connection.objects.convert_object_to_reference(@object, build: false)
        @arguments_references = @arguments.map { |argument| @connection.objects.convert_object_to_reference(argument, tentative: true) }
      end

      # Reject the call request.
      # To be called if the call could not be started.
      # The argument's references will be forgotten unless they are in use elsewhere.
      # @return [void]
      def rejected
        @arguments_references.each { |argument_reference| @connection.objects.reject_reference(argument_reference) }
      end

    end

  end
end
