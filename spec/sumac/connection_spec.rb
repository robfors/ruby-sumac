require 'sumac'

# make sure it exists
describe Sumac::Connection do

  def build_connection
    allow(Sumac::Calls).to receive(:new).and_return(instance_double('Sumac::Calls'))
    allow(Sumac::Closer).to receive(:new).and_return(instance_double('Sumac::Closer'))
    allow(Sumac::Handshake).to receive(:new).and_return(instance_double('Sumac::Handshake'))
    allow(Sumac::Messenger).to receive(:new).and_return(instance_double('Sumac::Messenger'))
    allow(Sumac::Objects).to receive(:new).and_return(instance_double('Sumac::Objects'))
    allow(Sumac::RemoteEntry).to receive(:new).and_return(instance_double('Sumac::RemoteEntry'))
    allow(Sumac::Connection::Scheduler).to receive(:new).and_return(instance_double('Sumac::Connection::Scheduler'))
    allow(Sumac::Shutdown).to receive(:new).and_return(instance_double('Sumac::Shutdown'))
    allow_any_instance_of(Sumac::Connection).to receive(:validate)
    connection = Sumac::Connection.new(local_entry: double, message_broker: double, object_request_broker: double)
    allow_any_instance_of(Sumac::Connection).to receive(:validate).and_call_original
    connection
  end

  # ::new
  example do
    entry = double
    message_broker = double
    object_request_broker = double
    calls = instance_double('Sumac::Calls')
    allow(Sumac::Calls).to receive(:new).and_return(calls)
    closer = instance_double('Sumac::Closer')
    allow(Sumac::Closer).to receive(:new).and_return(closer)
    handshake = instance_double('Sumac::Handshake')
    allow(Sumac::Handshake).to receive(:new).and_return(handshake)
    messenger = instance_double('Sumac::Messenger')
    allow(Sumac::Messenger).to receive(:new).and_return(messenger)
    objects = instance_double('Sumac::Objects')
    allow(Sumac::Objects).to receive(:new).and_return(objects)
    remote_entry = instance_double('Sumac::RemoteEntry')
    allow(Sumac::RemoteEntry).to receive(:new).and_return(remote_entry)
    scheduler = instance_double('Sumac::Connection::Scheduler')
    allow(Sumac::Connection::Scheduler).to receive(:new).and_return(scheduler)
    shutdown = instance_double('Sumac::Shutdown')
    allow(Sumac::Shutdown).to receive(:new).and_return(shutdown)
    allow_any_instance_of(Sumac::Connection).to receive(:validate)
    connection = Sumac::Connection.new(local_entry: entry, message_broker: message_broker, object_request_broker: object_request_broker)
    expect(Sumac::Calls).to have_received(:new).with(connection)
    expect(Sumac::Closer).to have_received(:new).with(connection)
    expect(Sumac::Handshake).to have_received(:new).with(connection)
    expect(Sumac::Messenger).to have_received(:new).with(connection)
    expect(Sumac::Objects).to have_received(:new).with(connection)
    expect(Sumac::RemoteEntry).to have_received(:new).with(no_args)
    expect(Sumac::Connection::Scheduler).to have_received(:new).with(connection)
    expect(Sumac::Shutdown).to have_received(:new).with(connection)
    expect(connection.instance_variable_get(:@local_entry)).to be(entry)
    expect(connection.instance_variable_get(:@message_broker)).to be(message_broker)
    expect(connection.instance_variable_get(:@object_request_broker)).to be(object_request_broker)
    expect(connection.instance_variable_get(:@calls)).to be(calls)
    expect(connection.instance_variable_get(:@closer)).to be(closer)
    expect(connection.instance_variable_get(:@handshake)).to be(handshake)
    expect(connection.instance_variable_get(:@messenger)).to be(messenger)
    expect(connection.instance_variable_get(:@objects)).to be(objects)
    expect(connection.instance_variable_get(:@remote_entry)).to be(remote_entry)
    expect(connection.instance_variable_get(:@scheduler)).to be(scheduler)
    expect(connection.instance_variable_get(:@shutdown)).to be(shutdown)
    expect(connection).to have_received(:validate).with(no_args)
    expect(connection).to be_a(Sumac::Connection)
  end

  # #any_calls?
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:any?).with(no_args).and_return(false)
    expect(connection.any_calls?).to be(false)
  end

  # #cancel_local_calls
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:cancel_local).with(no_args)
    connection.cancel_local_calls
  end

  # #cancel_remote_entry
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@remote_entry)).to receive(:cancel).with(no_args)
    connection.cancel_remote_entry
  end

  # #close
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:close)
    connection.close
  end

  # #closer
  example do
    connection = build_connection
    expect(connection.closer).to be(connection.instance_variable_get(:@closer))
  end

  # #close_messenger
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@messenger)).to receive(:close).with(no_args)
    connection.close_messenger
  end

  # #enable_close_requests
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@closer)).to receive(:enable).with(no_args)
    connection.enable_close_requests
  end

  # #forget
  example do
    connection = build_connection
    object = double
    future = instance_double('QuackConcurrency::Future')
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:forget, object).and_return(future)
    expect(connection.forget(object)).to be(future)
  end

  # #forget_objects
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@objects)).to receive(:forget).with(no_args)
    connection.forget_objects
  end

  # #initiate
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:initiate)
    connection.initiate
  end

  # #kill
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:kill)
    connection.kill
  end

  # #kill_messenger
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@messenger)).to receive(:kill).with(no_args)
    connection.kill_messenger
  end

  # #killed?
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@closer)).to receive(:killed?).with(no_args).and_return(false)
    expect(connection.killed?).to be(false)
  end

  # #local_entry
  example do
    connection = build_connection
    expect(connection.local_entry).to be(connection.instance_variable_get(:@local_entry))
  end

  # #mark_as_closed
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@closer)).to receive(:closed).with(no_args)
    connection.mark_as_closed
  end

  # #mark_messenger_as_closed
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@messenger)).to receive(:closed).with(no_args)
    connection.mark_messenger_as_closed
  end

  # #mark_as_killed
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@closer)).to receive(:killed).with(no_args)
    connection.mark_as_killed
  end

  # #messenger
  example do
    connection = build_connection
    expect(connection.messenger).to be(connection.instance_variable_get(:@messenger))
  end

  # #message_broker
  example do
    connection = build_connection
    expect(connection.message_broker).to be(connection.instance_variable_get(:@message_broker))
  end

  # #messenger_closed
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:messenger_closed)
    connection.messenger_closed
  end

  # #messenger_closed?
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@messenger)).to receive(:closed?).with(no_args).and_return(false)
    expect(connection.messenger_closed?).to be(false)
  end

  # #messenger_killed
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:messenger_killed)
    connection.messenger_killed
  end

  # #object_request_broker
  example do
    connection = build_connection
    expect(connection.object_request_broker).to be(connection.instance_variable_get(:@object_request_broker))
  end

  # #objects
  example do
    connection = build_connection
    expect(connection.objects).to be(connection.instance_variable_get(:@objects))
  end
  
  # #process_call_request
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:process_request)
    connection.process_call_request
  end

  # #process_call_request_message
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:process_request_message)
    connection.process_call_request_message
  end
  
  # #process_call_response
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:process_response)
    connection.process_call_response
  end
  
  # #process_call_response_message
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@calls)).to receive(:process_response_message)
    connection.process_call_response_message
  end
  
  # #process_compatibility_message
  example do
    connection = build_connection
    message = instance_double('Sumac::Messages::Compatibility')
    expect(connection.instance_variable_get(:@handshake)).to receive(:process_compatibility_message).with(message)
    connection.process_compatibility_message(message)
  end

  # #process_forget
  example do
    connection = build_connection
    object = double
    expect(connection.instance_variable_get(:@objects)).to receive(:process_forget).with(object, quiet: false)
    connection.process_forget(object, quiet: false)
  end
  
  # #process_forget_message
  example do
    connection = build_connection
    message = instance_double('Sumac::Messages::Forget')
    expect(connection.instance_variable_get(:@objects)).to receive(:process_forget_message).with(message, quiet: false)
    connection.process_forget_message(message, quiet: false)
  end

  # #process_initialization_message
  example do
    connection = build_connection
    message = instance_double('Sumac::Messages::Initialization')
    expect(connection.instance_variable_get(:@handshake)).to receive(:process_initialization_message).with(message)
    connection.process_initialization_message(message)
  end

  # #messenger_received_message

  # invalid_message
  example do
    connection = build_connection
    message_string = double
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_raise(Sumac::ProtocolError)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:invalid_message)
    connection.messenger_received_message(message_string)
  end

  # call_request_message
  example do
    connection = build_connection
    message_string = message_string
    message = instance_double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:call_request_message, message)
    connection.messenger_received_message(message_string)
  end

  # call_response_message
  example do
    connection = build_connection
    message_string = double
    message = instance_double('Sumac::Messages::CallResponse')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::CallResponse).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:call_response_message, message)
    connection.messenger_received_message(message_string)
  end

  # compatibility_message
  example do
    connection = build_connection
    message_string = double
    message = instance_double('Sumac::Messages::Compatibility')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::CallResponse).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Compatibility).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:compatibility_message, message)
    connection.messenger_received_message(message_string)
  end

  # forget_message
  example do
    connection = build_connection
    message_string = double
    message = instance_double('Sumac::Messages::Forget')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::CallResponse).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Compatibility).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Forget).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:forget_message, message)
    connection.messenger_received_message(message_string)
  end

  # initialization_message
  example do
    connection = build_connection
    message_string = double
    message = instance_double('Sumac::Messages::Initialization')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::CallResponse).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Compatibility).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Forget).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Initialization).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:initialization_message, message)
    connection.messenger_received_message(message_string)
  end

  # shutdown_message
  example do
    connection = build_connection
    message_string = double
    message = instance_double('Sumac::Messages::Shutdown')
    expect(Sumac::Messages).to receive(:from_json).with(message_string).and_return(message)
    expect(Sumac::Messages::CallRequest).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::CallResponse).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Compatibility).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Forget).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Initialization).to receive(:===).with(message).and_return(false)
    expect(Sumac::Messages::Shutdown).to receive(:===).with(message).and_return(true)
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:shutdown_message)
    connection.messenger_received_message(message_string)
  end

  # #remote_entry
  example do
    connection = build_connection
    expect(connection.remote_entry).to be(connection.instance_variable_get(:@remote_entry))
  end

  # #respond_to_call
  example do
    connection = build_connection
    call = double
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:call_response, call)
    connection.respond_to_call(call)
  end

  # #request_call
  example do
    connection = build_connection
    request = double
    future = instance_double('QuackConcurrency::Future')
    expect(connection.instance_variable_get(:@scheduler)).to receive(:receive).with(:call_request, request).and_return(future)
    connection.request_call(request)
  end

  # #send_compatibility_message
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@handshake)).to receive(:send_compatibility_message).with(no_args)
    connection.send_compatibility_message
  end

  # #send_initialization_message
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@handshake)).to receive(:send_initialization_message).with(no_args)
    connection.send_initialization_message
  end

  # #setup_messenger
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@messenger)).to receive(:setup).with(no_args)
    connection.setup_messenger
  end

  # #send_shutdown_message
  example do
    connection = build_connection
    expect(connection.instance_variable_get(:@shutdown)).to receive(:send_message).with(no_args)
    connection.send_shutdown_message
  end

  # #validate_request
  example do
    connection = build_connection
    calls = connection.instance_variable_get(:@calls)
    call = double
    expect(calls).to receive(:validate_request).with(call).and_return(false)
    expect(connection.validate_request(call)).to eq(false)
  end

  # #validate

  # message broker invalid
  example do
    connection = build_connection
    messenger = connection.instance_variable_get(:@messenger)
    expect(messenger).to receive(:validate_message_broker).with(no_args).and_raise(TypeError)
    expect{ connection.validate }.to raise_error(TypeError)
  end

  # local entry invalid
  example do
    connection = build_connection
    messenger = connection.instance_variable_get(:@messenger)
    expect(messenger).to receive(:validate_message_broker).with(no_args)
    handshake = connection.instance_variable_get(:@handshake)
    expect(handshake).to receive(:validate_local_entry).with(no_args).and_raise(Sumac::UnexposedObjectError)
    expect{ connection.validate }.to raise_error(Sumac::UnexposedObjectError)
  end

  # all valid
  example do
    connection = build_connection
    messenger = connection.instance_variable_get(:@messenger)
    expect(messenger).to receive(:validate_message_broker).with(no_args)
    handshake = connection.instance_variable_get(:@handshake)
    expect(handshake).to receive(:validate_local_entry).with(no_args)
    connection.validate
  end

end
