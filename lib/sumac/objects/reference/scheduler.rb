module Sumac
  class Objects
    class Reference

      # Manages the state of the {Reference} it belongs to and premforms transitions when events are received.
      # The state is related to the object's sendability and receivability.
      # @note only {#accept}, {#reject} and {#tentative} can be called on a tentative reference
      # @api private
      class Scheduler

        # Build a new {Scheduler} for {Reference}.
        # @param reference [Reference] being managed
        # @return [Scheduler]
        def initialize(reference, tentative: false)
          @reference = reference
          # possible states: tentative, active, forget_initiated, stale
          if tentative
            @state = :tentative
            @tentative_owners = 1
          else
            @state = :active
            @tentative_owners = 0
          end
        end

        def accept
          if at?(:tentative)
            @tentative_owners = 0
            to(:active)
          end
        end

        # Check if {Scheduler} is at one of the given states.
        # @param states [Array<String>]
        # @return [Boolean]
        def at?(*states)
          states.include?(@state)
        end

        # Inform the {Scheduler} of a request by the local application to forget the object.
        # @param quiet [Boolean] suppress any message to the remote endpoint
        # @return [void]
        def forget_locally(quiet: )
          if at?(:active)
            @reference.send_forget_message unless quiet
            to(:forget_initiated)
            @reference.no_longer_sendable
          end
        end

        # Inform the {Scheduler} of a request by the remote endpoint to forget the object.
        # @param quiet [Boolean] suppress any message to the remote endpoint
        # @return [void]
        def forgoten_remotely(quiet: )
          case @state
          when :active
            @reference.no_longer_receivable
            @reference.send_forget_message unless quiet
            to(:stale)
            @reference.no_longer_sendable
          when :forget_initiated
            @reference.no_longer_receivable
            to(:stale)
          end
        end

        def reject
          if at?(:tentative)
            @tentative_owners -= 1
            if @tentative_owners == 0
              @reference.no_longer_receivable
              @reference.no_longer_sendable
              to(:stale)
            end
          end
        end

        # Check if the reference can be received (has not been not forgoten remotely).
        # @return [Boolean]
        def receivable?
          at?(:active, :forget_initiated)
        end

        # Check if the reference can be sent (has not been not forgoten locally).
        # @return [Boolean]
        def sendable?
          at?(:active)
        end

        # Check if reference is stale (can not be sent and received).
        # Call {#sendable?} and {#receivable?} for a more detailed status.
        # @return [Boolean]
        def stale?
          at?(:stale)
        end

        def tentative
          @tentative_owners += 1 if at?(:tentative)
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
end
