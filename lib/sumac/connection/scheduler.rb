module Sumac
  class Connection

    # Manages the state of the object request broker and transitions when events are received.
    # Review the Sumac specification to better understand the states and transitions.
    # @api private
    class Scheduler

      # Build a new {Scheduler} for {Connection}.
      # @param connection [Connection] being managed
      # @return [Scheduler]
      def initialize(connection)
        @connection = connection
        @state = :initial
      end

      # Check if {Scheduler} is at one of the given states.
      # @param states [Array<Symbol>]
      # @return [Boolean]
      def at?(*states)
        states.include?(@state)
      end

      # A helper to invoke various actions when the broker is killed.
      # @param items [Array<Symbol>] actions to perform
      # @return [void]
      def kill(*items)
        @connection.mark_messenger_as_closed unless items.include?(:messenger)
        @connection.mark_as_killed
        @connection.forget_objects if items.include?(:objects)
        @connection.cancel_local_calls if items.include?(:calls)
        @connection.cancel_remote_entry if items.include?(:remote_entry)
        @connection.kill_messenger if items.include?(:messenger)
        if items.include?(:calls) && @connection.any_calls?
          @state = :kill
        elsif items.include?(:messenger)
          @state = :join
        else
          @connection.mark_as_closed
          @state = :close
        end
      end

      # Process an event and execute a transition of state if required.
      # @param type [Symbol] type of event
      # @param directive [Object] data specific to the event, passed directly back to {Connection} 
      # @raise [StandardError] errors raised will depend on the event being processed
      # @return [Object] objects returned will depend on the event being processed
      def receive(type, directive = nil)
        case @state
        
        when :initial
          @connection.send_compatibility_message
          @connection.setup_messenger
          to(:compatibility_handshake)
        
        when :compatibility_handshake
          case type
          when :compatibility_message
            begin
              @connection.process_compatibility_message(directive)
            rescue ProtocolError
              kill(:messenger, :remote_entry)
              return
            end
            @connection.send_initialization_message
            to(:initialization_handshake)
          when :messenger_closed, :messenger_killed
            kill(:remote_entry)
          else # kill, other message, invalid message
            kill(:messenger, :remote_entry)
          end
        
        when :initialization_handshake
          case type
          when :initialization_message
            begin
              @connection.process_initialization_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :remote_entry)
              return
            end
            @connection.enable_close_requests
            to(:active)
          when :messenger_closed, :messenger_killed
            kill(:remote_entry)
          else # kill, other message, invalid message
            kill(:messenger, :remote_entry)
          end
        
        when :active
          case type
          when :call_request
            @connection.process_call_request(directive)
          when :call_request_message
            begin
              @connection.process_call_request_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
         when :call_response
            @connection.process_call_response(directive, quiet: false)
          when :call_response_message
            begin
              @connection.process_call_response_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
          when :close
            @connection.send_shutdown_message
            to(:shutdown_initiated)
          when :forget
            @connection.process_forget(directive, quiet: false)
          when :forget_message
            begin
              @connection.process_forget_message(directive, quiet: false)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
          when :messenger_closed, :messenger_killed
            kill(:objects, :calls)
          when :shutdown_message
            @connection.send_shutdown_message
            if @connection.any_calls?
              to(:shutdown)
            else
              @connection.forget_objects
              @connection.close_messenger
              to(:join)
            end
          else # kill, other message, invalid message
            kill(:messenger, :objects, :calls)
          end

        when :shutdown_initiated
          case type
          when :call_request
            raise ClosedObjectRequestBrokerError
          when :call_request_message
            begin
              @connection.process_call_request_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
          when :call_response
            @connection.process_call_response(directive, quiet: false)
          when :call_response_message
            begin
              @connection.process_call_response_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
          when :close    
          when :forget
            @connection.process_forget(directive, quiet: true)
          when :forget_message
            begin
              @connection.process_forget_message(directive, quiet: true)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
          when :messenger_closed, :messenger_killed
            kill(:objects, :calls)
          when :shutdown_message
            if @connection.any_calls?
              to(:shutdown)
            else
              @connection.forget_objects
              @connection.close_messenger
              to(:join)
            end
          else #kill, other message, invalid message
            kill(:messenger, :objects, :calls)
          end

        when :shutdown
          case type
          when :call_request
            raise ClosedObjectRequestBrokerError
          when :call_response
            @connection.process_call_response(directive, quiet: false)
            unless @connection.any_calls?
              @connection.forget_objects
              @connection.close_messenger
              to(:join)
            end
          when :call_response_message
            begin
              @connection.process_call_response_message(directive)
            rescue ProtocolError
              kill(:messenger, :objects, :calls)
              return
            end
            unless @connection.any_calls?
              @connection.forget_objects
              @connection.close_messenger
              to(:join)
            end
          when :close
          when :forget
            @connection.process_forget(directive, quiet: true)
          when :messenger_closed, :messenger_killed
            kill(:objects, :calls)
          else #kill, other message, invalid message
            kill(:messenger, :objects, :calls)
          end

        when :kill
          case type
          when :call_request
            raise ClosedObjectRequestBrokerError
          when :call_response
            @connection.process_call_response(directive, quiet: true)
            unless @connection.any_calls?
              if @connection.messenger_closed?
                @connection.mark_as_closed
                to(:close)
              else
                to(:join)
              end
            end
          when :messenger_closed, :messenger_killed
            @connection.mark_messenger_as_closed
            unless @connection.any_calls?
              @connection.mark_as_closed
              to(:close)  
            end
          else # forget, close, kill, any message, invalid message
          end 

        when :join
          case type
          when :call_request
            raise ClosedObjectRequestBrokerError
          when :messenger_closed
            @connection.mark_messenger_as_closed
            @connection.mark_as_closed
            to(:close)
          when :messenger_killed
            @connection.mark_messenger_as_closed
            @connection.mark_as_killed unless @connection.killed?
            @connection.mark_as_closed
            to(:close)
          when :close, :forget
          else # kill, any message, invalid message
            unless @connection.killed?
              @connection.mark_as_killed
              @connection.kill_messenger
            end
          end

        when :close
          case type
          when :call_request
            raise ClosedObjectRequestBrokerError
          else # forget, close, kill
          end

        end
      end

      # Assign a new state to the {Scheduler}.
      # @param new_state [Symbol]
      # @return [void]
      def to(new_state)
        @state = new_state
      end

    end

  end
end
