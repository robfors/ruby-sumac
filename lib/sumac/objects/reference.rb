module Sumac
  class Objects

    # Points to an {ExposedObject} that can be called by either application.
    # @note only {#accept}, {#reject} and {#tentative} can be called on a tentative reference
    # @api private
    class Reference
      extend Forwardable

      # Create a new {Reference}.
      # @param connection [Connection] that the reference belongs to
      # @param id [Integer] id to be passed between endpoints
      # @return [Reference]
      def initialize(connection, id: , tentative: false)
        @connection = connection
        @forget_request_future = QuackConcurrency::Future.new
        @id = id
        @scheduler = Scheduler.new(self, tentative: tentative)
      end

      # @!method accept
      #   @see Scheduler#accept
      def_delegator :@scheduler, :accept

      # Forces the reference to be set as forgoten.
      # To be called on non-stale references before the connection is closed.
      # @return [void]
      def forget
        remote_forget_request(quiet: true)
      end

      # Returns the id of the reference.
      # @return [Integer]
      attr_reader :id

      # Called when the local applicaiton wants to forget the reference's object.
      # If called on an object that has already been forgoten the call will do nothing.
      # @param quiet [Boolean] suppress any message to the remote endpoint
      # @return [QuackConcurrency::Future] to be set when the remote endpoint has forgoten the object (it has acknowledged the request or the broker has closed)
      def local_forget_request(quiet: )
        @scheduler.forget_locally(quiet: quiet)
        @forget_request_future
      end

      # Called when the remote endpoint has acknowledged or sent a request to forget this object.
      # When called we can be confident that both endpoints will no longer try to send this
      # reference's id (at least not for this object).
      # @return [void]
      def no_longer_receivable
        @connection.objects.remove_reference(self)
        @forget_request_future.set
      end

      # To be called when the local endpoint sent or acknowledged a request to forget this object.
      # When called we know that the local endpoint must no longer send this object, however the
      # remote endpoint can still send it until it has acknowledged the request.
      # @abstract
      # @return [void]
      def no_longer_sendable
      end

      # Returns the exposed object this reference points to.
      # @return [ExposedObject]
      attr_reader  :object

      # @!method receivable?
      #   @see Scheduler#receivable?
      def_delegator :@scheduler, :receivable?

      # @!method reject
      #   @see Scheduler#reject
      def_delegator :@scheduler, :reject

      # Called when the remote applicaiton has forgoten the reference's object.
      # @param quiet [Boolean] suppress any message to the remote endpoint
      # @return [void]
      def remote_forget_request(quiet: )
        @scheduler.forgoten_remotely(quiet: quiet)  
      end

      # Build and send forget message to remote endpoint.
      # @return [void]
      def send_forget_message
        properties = @connection.objects.convert_reference_to_properties(self)
        message = Messages::Forget.build(object: properties)
        @connection.messenger.send(message)
      end

      # @!method sendable?
      #   @see Scheduler#sendable?
      def_delegator :@scheduler, :sendable?

      # @!method stale?
      #   @see Scheduler#stale?
      def_delegator :@scheduler, :stale?

      # @!method tentative
      #   @see Scheduler#tentative
      def_delegator :@scheduler, :tentative

    end

  end
end
