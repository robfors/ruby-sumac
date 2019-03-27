require 'sumac'

# make sure it exists
describe Sumac::Connection::Scheduler do

  # we will test the connection by setting it to all possible states and sending all possible (valid) directives for each state
  # under all possilbe conditions

  # states (chronological order):
  #   initial
  #   compatibility_handshake
  #   initialization_handshake
  #   active
  #   shutdown_initiated
  #   shutdown
  #   kill
  #   join
  #   close

  # directives (no particular order, just alphabetical):
  #   call_request
  #   call_request_message
  #   call_response
  #   call_response_message
  #   close
  #   compatibility_message
  #   forget
  #   forget_message
  #   initiate
  #   initialization_message
  #   invalid_message
  #   kill
  #   messenger_closed
  #   messenger_killed
  #   shutdown_message


  def setup_scheduler(start_state: , end_state: )
    connection = instance_double('Sumac::Connection')
    scheduler = Sumac::Connection::Scheduler.new(connection)
    scheduler.instance_variable_set(:@state, start_state)
    yield(scheduler, connection)
    expect(scheduler.instance_variable_get(:@state)).to eq end_state
  end


  # state: initial
  # receive: initiate
  # conditions:
  example do
    setup_scheduler(start_state: :initial, end_state: :compatibility_handshake) do |scheduler, connection|
      expect(connection).to receive(:send_compatibility_message).with(no_args)
      expect(connection).to receive(:setup_messenger).with(no_args)

      scheduler.receive(:initiate)
    end
  end


  # state: compatibility_handshake
  # receive: call_request_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: compatibility_handshake
  # receive: call_response_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: compatibility_handshake
  # receive: compatibility_message
  # conditions: not compatible
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:process_compatibility_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: compatibility_handshake
  # receive: compatibility_message
  # conditions: compatible
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :initialization_handshake) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:process_compatibility_message).with(message)
      expect(connection).to receive(:send_initialization_message).with(no_args)

      scheduler.receive(:compatibility_message, message)
    end
  end

  
  # state: compatibility_handshake
  # receive: forget_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: compatibility_handshake
  # receive: initialization_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Initialization')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: compatibility_handshake
  # receive: invalid_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:invalid_message)
    end
  end


  # state: compatibility_handshake
  # receive: kill
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:kill)
    end
  end


  # state: compatibility_handshake
  # receive: messenger_closed
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: compatibility_handshake
  # receive: messenger_killed
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: compatibility_handshake
  # receive: shutdown_message
  # conditions:
  example do
    setup_scheduler(start_state: :compatibility_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: initialization_handshake
  # receive: call_request_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: initialization_handshake
  # receive: call_response_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: initialization_handshake
  # receive: compatibility_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: initialization_handshake
  # receive: forget_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: initialization_handshake
  # receive: initialization_message
  # conditions: entry object invalid
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Initialization')

      expect(connection).to receive(:process_initialization_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: initialization_handshake
  # receive: initialization_message
  # conditions: entry object valid
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :active) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:process_initialization_message).with(message)
      expect(connection).to receive(:enable_close_requests).with(no_args)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: initialization_handshake
  # receive: invalid_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:invalid_message)
    end
  end


  # state: initialization_handshake
  # receive: kill
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:kill)
    end
  end


  # state: initialization_handshake
  # receive: messenger_closed
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end

  
  # state: initialization_handshake
  # receive: messenger_killed
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: initialization_handshake
  # receive: shutdown_message
  # conditions:
  example do
    setup_scheduler(start_state: :initialization_handshake, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_remote_entry).with(no_args)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: active
  # receive: call_request
  # conditions: request invalid (UnexposedObjectError raised)
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      request = double

      expect(connection).to receive(:process_call_request).with(request).and_raise(Sumac::UnexposedObjectError)

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::UnexposedObjectError)
    end
  end


  # state: active
  # receive: call_request
  # conditions: request invalid (StaleObjectError raised)
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      request = double

      expect(connection).to receive(:process_call_request).with(request).and_raise(Sumac::StaleObjectError)

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::StaleObjectError)
    end
  end


  # state: active
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      request = double
      future = instance_double('QuackConcurrency::Future')

      expect(connection).to receive(:process_call_request).with(request).and_return(future)

      expect(scheduler.receive(:call_request, request)).to be(future)
    end
  end


  # state: active
  # receive: call_request_message
  # conditions: message invalid, no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: active
  # receive: call_request_message
  # conditions: message invalid, ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: active
  # receive: call_request_message
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: active
  # receive: call_response
  # conditions:
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: false)

      scheduler.receive(:call_response, response)
    end
  end


  # state: active
  # receive: call_response_message
  # conditions: message invalid, no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: active
  # receive: call_response_message
  # conditions: message invalid, ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: active
  # receive: call_response_message
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: active
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :active, end_state: :shutdown_initiated) do |scheduler, connection|
      expect(connection).to receive(:send_shutdown_message).with(no_args)

      scheduler.receive(:close)
    end
  end


  # state: active
  # receive: compatibility_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: active
  # receive: compatibility_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: active
  # receive: forget
  # conditions: object is not exposed for this connection
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      object = double

      expect(connection).to receive(:process_forget).with(object, quiet: false).and_raise(Sumac::UnexposedObjectError)

      expect{ scheduler.receive(:forget, object) }.to raise_error(Sumac::UnexposedObjectError)
    end
  end


  # state: active
  # receive: forget
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      object = double
      future = instance_double('QuackConcurrency::Future')

      expect(connection).to receive(:process_forget).with(object, quiet: false).and_return(future)

      expect(scheduler.receive(:forget, object)).to be(future)
    end
  end


  # state: active
  # receive: forget_message
  # conditions: invalid message (object does not exist, already forgoten, ...), no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: false).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: active
  # receive: forget_message
  # conditions: invalid message (object does not exist, already forgoten, ...), ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: false).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: active
  # receive: forget_message
  # conditions: valid message, succeeds
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: false)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: active
  # receive: initialization_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: active
  # receive: initialization_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: active
  # receive: invalid_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:invalid_message)
    end
  end


  # state: active
  # receive: invalid_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:invalid_message)
    end
  end


  # state: active
  # receive: kill
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:kill)
    end
  end


  # state: active
  # receive: kill
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:kill)
    end
  end


  # state: active
  # receive: messenger_closed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: active
  # receive: messenger_closed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: active
  # receive: messenger_killed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: active
  # receive: messenger_killed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: active
  # receive: shutdown_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :active, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:send_shutdown_message).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:close_messenger).with(no_args)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: active
  # receive: shutdown_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :active, end_state: :shutdown) do |scheduler, connection|
      expect(connection).to receive(:send_shutdown_message).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: shutdown_initiated
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      request = double

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::ClosedObjectRequestBrokerError)
    end
  end


  # state: shutdown_initiated
  # receive: call_request_message
  # conditions: message invalid, no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: call_request_message
  # conditions: message invalid, ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: call_request_message
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:process_call_request_message).with(message)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: call_response
  # conditions:
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: false)

      scheduler.receive(:call_response, response)
    end
  end


  # state: shutdown_initiated
  # receive: call_response_message
  # conditions: message invalid, no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: call_response_message
  # conditions: message invalid, ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: call_response_message
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      scheduler.receive(:close)
    end
  end


  # state: shutdown_initiated
  # receive: compatibility_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: compatibility_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: forget
  # conditions: object is not exposed for this connection
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      object = double

      expect(connection).to receive(:process_forget).with(object, quiet: true).and_raise(Sumac::UnexposedObjectError)

      expect{ scheduler.receive(:forget, object) }.to raise_error(Sumac::UnexposedObjectError)
    end
  end


  # state: shutdown_initiated
  # receive: forget
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      object = double
      future = instance_double('QuackConcurrency::Future')

      expect(connection).to receive(:process_forget).with(object, quiet: true).and_return(future)

      expect(scheduler.receive(:forget, object)).to be(future)
    end
  end


  # state: shutdown_initiated
  # receive: forget_message
  # conditions: invalid message (object does not exist, already forgoten, ...), no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: true).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: forget_message
  # conditions: invalid message (object does not exist, already forgoten, ...), ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: true).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: forget_message
  # conditions: valid message
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown_initiated) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:process_forget_message).with(message, quiet: true)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: initialization_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: initialization_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: shutdown_initiated
  # receive: invalid_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:invalid_message)
    end
  end


  # state: shutdown_initiated
  # receive: invalid_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:invalid_message)
    end
  end


  # state: shutdown_initiated
  # receive: kill
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:kill)
    end
  end


  # state: shutdown_initiated
  # receive: kill
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:kill)
    end
  end


  # state: shutdown_initiated
  # receive: messenger_closed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: shutdown_initiated
  # receive: messenger_closed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: shutdown_initiated
  # receive: messenger_killed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: shutdown_initiated
  # receive: messenger_killed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: shutdown_initiated
  # receive: shutdown_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:close_messenger).with(no_args)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: shutdown_initiated
  # receive: shutdown_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown_initiated, end_state: :shutdown) do |scheduler, connection|
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: shutdown
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      request = double

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::ClosedObjectRequestBrokerError)
    end
  end


  # state: shutdown
  # receive: call_request_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: shutdown
  # receive: call_request_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: shutdown
  # receive: call_response
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: false)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:close_messenger).with(no_args)

      scheduler.receive(:call_response, response)
    end
  end


  # state: shutdown
  # receive: call_response
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: false)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response, response)
    end
  end


  # state: shutdown
  # receive: call_response_message
  # conditions: message invalid, no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown
  # receive: call_response_message
  # conditions: message invalid, ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message).and_raise(Sumac::ProtocolError)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown
  # receive: call_response_message
  # conditions: succeeds, no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:close_messenger).with(no_args)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown
  # receive: call_response_message
  # conditions: succeeds, ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:process_call_response_message).with(message)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: shutdown
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      scheduler.receive(:close)
    end
  end


  # state: shutdown
  # receive: compatibility_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: shutdown
  # receive: compatibility_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: shutdown
  # receive: forget
  # conditions: object is not exposed for this connection
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      object = double

      expect(connection).to receive(:process_forget).with(object, quiet: true).and_raise(Sumac::UnexposedObjectError)

      expect{ scheduler.receive(:forget, object) }.to raise_error(Sumac::UnexposedObjectError)
    end
  end


  # state: shutdown
  # receive: forget
  # conditions: succeeds
  example do
    setup_scheduler(start_state: :shutdown, end_state: :shutdown) do |scheduler, connection|
      object = double
      future = instance_double('QuackConcurrency::Future')

      expect(connection).to receive(:process_forget).with(object, quiet: true).and_return(future)

      expect(scheduler.receive(:forget, object)).to be(future)
    end
  end


  # state: shutdown
  # receive: forget_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: shutdown
  # receive: forget_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: shutdown
  # receive: initialization_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: shutdown
  # receive: initialization_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: shutdown
  # receive: invalid_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:invalid_message)
    end
  end


  # state: shutdown
  # receive: invalid_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:invalid_message)
    end
  end


  # state: shutdown
  # receive: kill
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:kill)
    end
  end


  # state: shutdown
  # receive: kill
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:kill)
    end
  end


  # state: shutdown
  # receive: messenger_closed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: shutdown
  # receive: messenger_closed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: shutdown
  # receive: messenger_killed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: shutdown
  # receive: messenger_killed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: shutdown
  # receive: shutdown_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :shutdown, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: shutdown
  # receive: shutdown_message
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :shutdown, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)
      expect(connection).to receive(:cancel_local_calls).with(no_args)
      expect(connection).to receive(:forget_objects).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: kill
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      request = double

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::ClosedObjectRequestBrokerError)
    end
  end


  # state: kill
  # receive: call_request_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: kill
  # receive: call_response
  # conditions: no ongoing calls, messenger open
  example do
    setup_scheduler(start_state: :kill, end_state: :join) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: true)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:messenger_closed?).with(no_args).and_return(false)

      scheduler.receive(:call_response, response)
    end
  end


  # state: kill
  # receive: call_response
  # conditions: no ongoing calls, messenger closed
  example do
    setup_scheduler(start_state: :kill, end_state: :close) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: true)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:messenger_closed?).with(no_args).and_return(true)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:call_response, response)
    end
  end


  # state: kill
  # receive: call_response
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      response = double

      expect(connection).to receive(:process_call_response).with(response, quiet: true)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:call_response, response)
    end
  end


  # state: kill
  # receive: call_response_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: kill
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      scheduler.receive(:close)
    end
  end


  # state: kill
  # receive: compatibility_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: kill
  # receive: forget
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      object = double

      scheduler.receive(:forget, object)
    end
  end


  # state: kill
  # receive: forget_message
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      scheduler.receive(:forget_message, message)
    end
  end


  # state: kill
  # receive: initialization_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: kill
  # receive: invalid_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      scheduler.receive(:invalid_message)
    end
  end


  # state: kill
  # receive: kill
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      scheduler.receive(:kill)
    end
  end


  # state: kill
  # receive: messenger_closed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :kill, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: kill
  # receive: messenger_closed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: kill
  # receive: messenger_killed
  # conditions: no ongoing calls
  example do
    setup_scheduler(start_state: :kill, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: kill
  # receive: messenger_killed
  # conditions: ongoing call
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:any_calls?).with(no_args).and_return(true)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: kill
  # receive: shutdown_message
  # conditions:
  example do
    setup_scheduler(start_state: :kill, end_state: :kill) do |scheduler, connection|
      scheduler.receive(:shutdown_message)
    end
  end


  # state: join
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      request = double

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::ClosedObjectRequestBrokerError)
    end
  end


  # state: join
  # receive: call_request_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: join
  # receive: call_request_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallRequest')

      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:call_request_message, message)
    end
  end


  # state: join
  # receive: call_response_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: join
  # receive: call_response_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::CallResponse')

      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:call_response_message, message)
    end
  end


  # state: join
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      scheduler.receive(:close)
    end
  end


  # state: join
  # receive: compatibility_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: join
  # receive: compatibility_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:compatibility_message, message)
    end
  end


  # state: join
  # receive: forget
  # conditions:
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      object = double

      scheduler.receive(:forget, object)
    end
  end


  # state: join
  # receive: forget_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: join
  # receive: forget_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Forget')

      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:forget_message, message)
    end
  end


  # state: join
  # receive: initialization_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: join
  # receive: initialization_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      message = instance_double('Sumac::Messages::Compatibility')

      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:initialization_message, message)
    end
  end


  # state: join
  # receive: invalid_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:invalid_message)
    end
  end


  # state: join
  # receive: invalid_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:invalid_message)
    end
  end


  # state: join
  # receive: kill
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:kill)
    end
  end


  # state: join
  # receive: kill
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:kill)
    end
  end


  # state: join
  # receive: messenger_closed
  # conditions:
  example do
    setup_scheduler(start_state: :join, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_closed)
    end
  end


  # state: join
  # receive: messenger_killed
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: join
  # receive: messenger_killed
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :close) do |scheduler, connection|
      expect(connection).to receive(:mark_messenger_as_closed).with(no_args)
      expect(connection).to receive(:killed?).with(no_args).and_return(true)
      expect(connection).to receive(:mark_as_closed).with(no_args)

      scheduler.receive(:messenger_killed)
    end
  end


  # state: join
  # receive: shutdown_message
  # conditions: not killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(false)
      expect(connection).to receive(:mark_as_killed).with(no_args)
      expect(connection).to receive(:kill_messenger).with(no_args)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: join
  # receive: shutdown_message
  # conditions: killed
  example do
    setup_scheduler(start_state: :join, end_state: :join) do |scheduler, connection|
      expect(connection).to receive(:killed?).with(no_args).and_return(true)

      scheduler.receive(:shutdown_message)
    end
  end


  # state: close
  # receive: call_request
  # conditions:
  example do
    setup_scheduler(start_state: :close, end_state: :close) do |scheduler, connection|
      request = double

      expect{ scheduler.receive(:call_request, request) }.to raise_error(Sumac::ClosedObjectRequestBrokerError)
    end
  end


  # state: close
  # receive: close
  # conditions:
  example do
    setup_scheduler(start_state: :close, end_state: :close) do |scheduler, connection|
      scheduler.receive(:close)
    end
  end


  # state: close
  # receive: forget
  # conditions:
  example do
    setup_scheduler(start_state: :close, end_state: :close) do |scheduler, connection|
      object = double

      scheduler.receive(:forget, object)
    end
  end


  # state: close
  # receive: kill
  # conditions:
  example do
    setup_scheduler(start_state: :close, end_state: :close) do |scheduler, connection|
      scheduler.receive(:kill)
    end
  end

end
