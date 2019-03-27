require 'sumac'


  # this file runs smoke testing to ensure that the interface to the application works on a high level.
  # we will only test unique (valid) inputs for a given state
  # note: 'unique' implies that we will not test inputs that will have a duplicate effect on the broker as
  #   it's lower level behaviour has already been tested in lower level tests, particularly in the {Scheduler} spec


  # broker states (chronological order):
  #   initial
  #   compatibility_handshake
  #   initialization_handshake
  #   active
  #   shutdown_initiated
  #   shutdown
  #   kill
  #   join
  #   close
  # object states (chronological order):
  #   active
  #   forget_initiated
  #   stale

  # directives (no particular order, just alphabetical):
  #   call
  #   call_request_message
  #   call_response_message
  #   close
  #   closed?
  #   compatibility_message
  #   entry
  #   forget
  #   forget_message
  #   initiate
  #   initialization_message
  #   invalid_message
  #   join
  #   kill
  #   killed?
  #   messenger_closed
  #   messenger_killed
  #   receivable?
  #   respond
  #   sendable?
  #   shutdown_message
  #   stale?


class MessageBrokerDouble
  include RSpec::Matchers

  def initialize
    @directives = []
  end

  # methods for broker

  def close
    @directives << [:close]
  end

  def kill
    @directives << [:kill]
  end

  def object_request_broker=(object_request_broker)
    @object_request_broker = object_request_broker
  end

  def send(message_string)
    @directives << [:send, message_string]
  end

  # methods for tester

  def expect_received_close
    directive = @directives.shift
    expect(directive&.at(0)).to eq(:close)
  end

  def expect_received_kill
    directive = @directives.shift
    expect(directive&.at(0)).to eq(:kill)
  end

  def expect_received_message(message_string)
    directive = @directives.shift
    expect(directive&.at(0)).to eq(:send)
    expect(directive[1]).to eq(message_string)
  end

  def expect_received_nothing
    expect(@directives.empty?).to be(true)
  end

  def send_close
    @object_request_broker.messenger_closed
  end

  def send_kill
    @object_request_broker.messenger_killed
  end

  def send_message(message_string)
    @object_request_broker.messenger_received_message(message_string)
  end

end


describe do


  def build_message_broker
    message_broker = MessageBrokerDouble.new
  end


  # ---------- test creation of broker ----------


  # create a broker with an invalid mssage_broker
  example do
    entry = nil
    message_broker = double

    expect{ Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker) }.to raise_error(TypeError)
  end


  # create a broker with an invalid local_entry
  example do
    entry = Object.new
    message_broker = build_message_broker

    expect{ Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker) }.to raise_error(Sumac::UnexposedObjectError)
  end


  # create a broker with valid arguments
  example do
    entry = nil
    message_broker = build_message_broker

    expect(message_broker).to receive(:send).with({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)

    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
  end


  # try to send compatibility_message too soon (when the callback is set is the earliest we can send it)
  #   it should be queued until broker is ready for it
  example do
    entry = nil
    message_broker = build_message_broker

    def message_broker.on_message(&callback)
      @on_message_callback = callback
      Thread.new { callback.call({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json) }
      sleep 1
    end

    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
  end


  # ---------- test invalid/unexpected input from remote endpoint ----------


  # test an invalid input, this will include:
  #   any unexpected message (wrong type), an unparsable message, invalid message (missing/unexpected properties)
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'unexpected' => 'property' }.to_json)
    message_broker.expect_received_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(false)
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
  end


  # test an invalid input, at join state
  # this is the only case where the message_broker will receive 'close' and 'kill'
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_close
    expect(broker.killed?).to be(false)
    message_broker.send_message('invalid message')
    message_broker.expect_received_kill
    expect(broker.killed?).to be(true)
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
    message_broker.expect_received_nothing
  end


  # invalid entry object
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: initialization ---
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 2 }}.to_json)
    message_broker.expect_received_kill
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
  end


  # try passing object nested too deep to local endpoint
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    map = { 'object_type' => 'array', 'elements' => [{ 'object_type' => 'array', 'elements' => [{ 'object_type' => 'integer', 'value' => 1 }] }] }
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [map] }.to_json)
    message_broker.expect_received_kill
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
  end


  # --------- test uncompatible remote endpoint ---------


  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    # --- state: compatibility ---
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => 'invalid' }.to_json)
    message_broker.expect_received_kill
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
  end


  # --------- test entry ---------

  # ensure the remote entry is unlocked as soon as it is set
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: initialization ---
    thread = Thread.new { expect(broker.entry).to eq(0) }
    sleep 1
    expect(thread.alive?).to be(true)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'integer', 'value' => 0 }}.to_json)
    sleep 1
    expect(thread.alive?).to be(false) # no need to join it
  end

  # ensure the remote entry is unlocked when broker is killed but remote entry is not yet set
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: initialization ---
    thread = Thread.new { expect{ broker.entry }.to raise_error(Sumac::ClosedObjectRequestBrokerError) }
    sleep 1
    expect(thread.alive?).to be(true)
    broker.kill
    sleep 1
    expect(thread.alive?).to be(false) # no need to join it
  end

  # --------- test kill ---------


  # test kill from local application
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    broker.kill
    message_broker.expect_received_kill
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
  end


  # --------- test messenger_closed and messenger_killed ---------


  # test messenger_closed
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_close
    message_broker.expect_received_nothing
  end


  # test messenger_killed
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_kill
    message_broker.expect_received_nothing
  end


  # messenger killed right at the end
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_close
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
    message_broker.expect_received_nothing
  end


  # --------- test closed? and killed? ---------

  # closed gracefully, no ongoing calls
  # for this test the remote endpoint initiated the shutdown, for the next we will have the local application do it
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.expect_received_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(true)
    message_broker.expect_received_nothing
  end

  # closed gracefully, one ongoing call
  # the local application will initiate shutdown
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    thread1 = Thread.new { broker.entry.m }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    thread2 = Thread.new { broker.close }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(false)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    message_broker.expect_received_close
    message_broker.send_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(true)
    message_broker.expect_received_nothing
    [thread1, thread2].each(&:join)
  end


  # --------- test close ---------


  # no ongoing calls
  # call close before the connection is active to ensure the request to close is queued until the active state
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    # --- state: compatibility ---
    close_thread = Thread.new { broker.close }
    sleep 1
    expect(close_thread.alive?).to be(true)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_close
    expect(close_thread.alive?).to be(true)
    message_broker.send_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(true)
    sleep 1
    expect(close_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
  end


  # an ongoing call
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new { broker.entry.m }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    close_thread = Thread.new { broker.close }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    message_broker.expect_received_close
    expect(close_thread.alive?).to be(true)
    message_broker.send_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(true)
    sleep 1
    expect(close_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
    call_thread.join
  end


  # --------- test calls ---------


  # test calling a stale object
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    forget_thread = Thread.new { broker.entry.forget }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 } }.to_json)
    call_thread = Thread.new { expect{ broker.entry.m }.to raise_error(Sumac::StaleObjectError) }
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
    expect(broker.killed?).to be(false)
    broker.kill; sleep 1 # just to clean up forget_thread
  end


  # test passing and returning a few primitive types to remote endpoint
  # Boolean, Float, String, Array, Map
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      expect(broker.entry.m([{'a' => 1.2}, 3])).to eq([{'bc' => 2.3}, 4])
    end
    sleep 1
    arguments = [{ 'object_type' => 'array', 'elements' => [{ 'object_type' => 'map', 'pairs' => [{'key' => { 'object_type' => 'string', 'value' => 'a' }, 'value' => { 'object_type' => 'float', 'value' => 1.2 } }] }, { 'object_type' => 'integer', 'value' => 3 }] }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    return_value = { 'object_type' => 'array', 'elements' => [{ 'object_type' => 'map', 'pairs' => [{'key' => { 'object_type' => 'string', 'value' => 'bc' }, 'value' => { 'object_type' => 'float', 'value' => 2.3 } }] }, { 'object_type' => 'integer', 'value' => 4 }] }
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => return_value }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
  end


  # test passing and returning some local exposed objects to remote endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      klass = Class.new { include Sumac::Expose }
      object1 = klass.new
      object2 = klass.new
      expect(broker.entry.m(object1, object2)).to eq([object1,object2])
    end
    sleep 1
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }, { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    return_value = { 'object_type' => 'array', 'elements' => [{ 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }] }
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => return_value }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    expect(broker.killed?).to be(false)
  end



  # objects sent to the remote endpoint with an accepted call should be remembered by the local endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    klass = Class.new { include Sumac::Expose }
    object = klass.new
    call_thread = Thread.new { broker.entry.m(object) }
    sleep 1
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@local_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(false)
  end


  # objects sent to the remote endpoint with a rejected call should not be remembered by the local endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    klass = Class.new { include Sumac::Expose }
    object = klass.new
    call_thread = Thread.new { broker.entry.m(object) rescue nil }
    sleep 1
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception' }  }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@local_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(true)
  end


  # objects sent to the remote endpoint with a rejected and accepted call should be remembered by the local endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    klass = Class.new { include Sumac::Expose }
    object = klass.new
    require 'pry'
    call_thread1 = Thread.new { broker.entry.m(object) rescue nil }
    sleep 1
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    #$debug = true
    call_thread2 = Thread.new { broker.entry.m(object) }
    sleep 1
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception' }  }.to_json)
    sleep 1
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'null' }  }.to_json)
    sleep 1
    expect(call_thread1.alive?).to be(false) # no need to join it
    expect(call_thread2.alive?).to be(false) # no need to join it
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@local_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(false)
  end


  # objects received from the remote endpoint with an accepted call should be remembered by the local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@remote_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(false)
  end


  # objects received from the remote endpoint with a rejected call should not be remembered by the local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception', 'message' => 'wrong number of arguments (given 1, expected 0)' } }.to_json)
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@remote_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(true)
  end


  # objects received from the remote endpoint with an accepted then rejected call should be remembered by the local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }]
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'w', 'arguments' => arguments }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'unexposed_method_exception' } }.to_json)
    expect(broker.killed?).to be(false)
    id_table = broker.instance_variable_get(:@connection).objects.instance_variable_get(:@remote_references).instance_variable_get(:@id_table)
    expect(id_table.empty?).to be(false)
  end


  # test remote object
  # initiate the forget request from local application
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(true)
    expect(broker.entry.stale?).to be(false)
    forget_thread = Thread.new { broker.entry.forget }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 } }.to_json)
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(false)
    message_broker.send_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    sleep 1
    expect(forget_thread.alive?).to be(false) # no need to join it
    expect(broker.entry.receivable?).to be(false)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(true)
  end


  # test passing a remote stale object
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      object = broker.entry.m
      object.forget
      expect{ broker.entry.m(object) }.to raise_error(Sumac::StaleObjectError)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 } }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 } }.to_json)
    message_broker.send_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
    expect(broker.killed?).to be(false)
  end


  # test passing and returning some remote exposed objects to local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a,b); [a,b]; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    arguments = [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }, { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 }]
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => arguments }.to_json)
    sleep 1
    return_value = { 'object_type' => 'array', 'elements' => [{ 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }] }
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => return_value }.to_json)    
    expect(broker.killed?).to be(false)
  end


  # test passing and returning an object nested too max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      object = { 'a' => 1 }
      expect(broker.entry.m(object)).to eq(object)
    end
    sleep 1
    map = { 'object_type' => 'map', 'pairs' => [{ 'key' => { 'object_type' => 'string', 'value' => 'a' }, 'value' => { 'object_type' => 'integer', 'value' => 1 }}] }
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [map] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => map }.to_json)
    sleep 1
    message_broker.expect_received_nothing
    expect(call_thread.alive?).to be(false) # no need to join it
    expect(broker.killed?).to be(false)
  end


  # try passing object nested too deep to remote endpoint
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    object = { 'a' => [] }
    expect{ broker.entry.m(object) }.to raise_error(Sumac::UnexposedObjectError)
    message_broker.expect_received_nothing
    expect(broker.killed?).to be(false)
  end


  # test passing wrong number of arguments to local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'integer', 'value' => 1 },{ 'object_type' => 'boolean', 'value' => true }] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception', 'message' => 'wrong number of arguments (given 2, expected 1)' } }.to_json)
  end


  # test passing correct number of arguments to local endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m(a, b); raise unless a == 1 && b == true; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'integer', 'value' => 1 },{ 'object_type' => 'boolean', 'value' => true }] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
  end


  # test returning a raised error raised by remote endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      begin
        broker.entry.m
      rescue Sumac::RemoteError => error
        expect(error.remote_message).to eq('abc')
        expect(error.remote_type).to eq('TypeError')
      else
        raise 'test failed'
      end
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'exception' => { 'object_type' => 'exception', 'class' => 'TypeError', 'message' => 'abc' } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
  end


  # test returning a raised error raised by local application
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m; raise(TypeError.new('abc')); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'exception' => { 'object_type' => 'exception', 'class' => 'TypeError', 'message' => 'abc' } }.to_json)
  end


  # test returning a raised error raised by local application from a nested namespace
  example do
    stub_const('N', Module.new)
    N::E = Class.new(StandardError)
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m; raise(N::E.new); end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'exception' => { 'object_type' => 'exception', 'class' => 'N::E' } }.to_json)
  end


  # call an unexposed method on the local application
  # !!!important security test!!!
  example do
    entry = (Class.new { include Sumac::Expose; def m; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'unexposed_method_exception' } }.to_json)
  end


  # return an unexposed object from the local application
  # !!!important security test!!!
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m; Object.new; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'exception' => { 'object_type' => 'exception', 'class' => 'Sumac::UnexposedObjectError', 'message' => 'object has not been exposed, it can not be send to remote endpoint' } }.to_json)
  end


  # two asynchronous local calls
  # check that the ids are reused
  # check that call from the application returns at the correct time
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call1_thread = Thread.new do
      expect(broker.entry.a).to eq(0)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'a', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 0 } }.to_json)
    sleep 1
    expect(call1_thread.alive?).to be(false) # no need to join it

    call2_thread = Thread.new do
      expect(broker.entry.b).to eq(1)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'b', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } }.to_json)
    sleep 1
    expect(call2_thread.alive?).to be(false) # no need to join it
  end


  # three synchronous local calls
  # check that the ids don't get mixed up buy testing for the correct return values
  # check that call from the application returns at the correct time
  # return the calls out of their incoming order
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---

    call1_thread = Thread.new do
      expect(broker.entry.a).to eq(0)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'a', 'arguments' => [] }.to_json)
    
    call2_thread = Thread.new do
      expect(broker.entry.b).to eq(1)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'b', 'arguments' => [] }.to_json)

    call3_thread = Thread.new do
      expect(broker.entry.c).to eq(2)
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 2, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'c', 'arguments' => [] }.to_json)
    
    expect(call1_thread.alive?).to be(true) # no need to join it
    expect(call2_thread.alive?).to be(true) # no need to join it
    expect(call3_thread.alive?).to be(true) # no need to join it
    
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 0 } }.to_json)
    sleep 1
    expect(call1_thread.alive?).to be(false) # no need to join it

    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 2, 'return_value' => { 'object_type' => 'integer', 'value' => 2 } }.to_json)
    sleep 1
    expect(call3_thread.alive?).to be(false) # no need to join it

    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } }.to_json)
    sleep 1
    expect(call2_thread.alive?).to be(false) # no need to join it
  end


  # two asynchronous remote calls
  # check that the correct ids are returned
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :a; expose_method :b; def a; 0; end; def b; 1; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'a', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'b', 'arguments' => [] }.to_json)
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } }.to_json)
  end


  # two synchronous remote calls
  # check that the return values don't get mixed up
  # return the calls out of their incoming order
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :a; expose_method :b; def a; sleep 1; 0; end; def b; 1; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'a', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'b', 'arguments' => [] }.to_json)
    sleep 2
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'integer', 'value' => 0 } }.to_json)
  end


  # one local call, broker gets killed
  # check that call from the application returns
  # we will kill it by responding to a non-existent call
  # as soon as the call is returned to the application, typically we would expect the application to check if the broker has been killed, so try that here
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    call_thread = Thread.new do
      expect{ broker.entry.m }.to raise_error(Sumac::StaleObjectError)
      expect(broker.killed?).to be(true) # we would want to know if the object has been explicitly forgoten or if the broker was killed
    end
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_kill
    expect(broker.killed?).to be(true)
  end


  # one remote call, broker gets killed
  # broker should wait for call to finish but not return it to the remote endpoint
  example do
    entry = (Class.new { include Sumac::Expose; expose_method :m; def m; sleep 2; end }).new
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    message_broker.send_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [] }.to_json)
    sleep 1
    expect(broker.killed?).to be(false)
    broker.kill
    message_broker.expect_received_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(false)
    sleep 2
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
    message_broker.expect_received_nothing
  end


  # --------- test test forgetting object, #receivable?, #sendable?, #stale? ---------


  # test remote object
  # initiate the forget request from local application
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(true)
    expect(broker.entry.stale?).to be(false)
    forget_thread = Thread.new { broker.entry.forget }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 } }.to_json)
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(false)
    message_broker.send_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    sleep 1
    expect(forget_thread.alive?).to be(false) # no need to join it
    expect(broker.entry.receivable?).to be(false)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(true)
  end


  # test remote object
  # initiate the forget request from remote endpoint
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(true)
    expect(broker.entry.stale?).to be(false)
    message_broker.send_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 } }.to_json)
    expect(broker.entry.receivable?).to be(false)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(true)
    message_broker.expect_received_nothing
  end


  # broker is killed
  # object will be immediately forgoten
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    expect(broker.entry.receivable?).to be(true)
    expect(broker.entry.sendable?).to be(true)
    expect(broker.entry.stale?).to be(false)
    broker.kill
    expect(broker.entry.receivable?).to be(false)
    expect(broker.entry.sendable?).to be(false)
    expect(broker.entry.stale?).to be(true)
  end


  # should be able to send a local object (with a new id) after it has been forgoten
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    # --- state: active ---
    object = (Class.new { include Sumac::Expose; }).new
    call_thread = Thread.new { expect(broker.entry.m(object)).to be_nil }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }] }.to_json)
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
    message_broker.send_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 } }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 } }.to_json)
    call_thread = Thread.new { expect(broker.entry.m(object)).to be_nil }
    sleep 1
    message_broker.expect_received_message({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 0 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 0 }] }.to_json)
    # clean up thread
    message_broker.send_message({ 'message_type' => 'call_response', 'id' => 0, 'return_value' => { 'object_type' => 'null' } }.to_json)
    sleep 1
    expect(call_thread.alive?).to be(false) # no need to join it
  end


  # --------- test join ---------


  # #join should return when broker is closed
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    join_thread = Thread.new { broker.join }
    message_broker.send_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'shutdown' }.to_json)
    message_broker.expect_received_close
    expect(join_thread.alive?).to be(true)
    message_broker.send_close
    expect(broker.killed?).to be(false)
    expect(broker.closed?).to be(true)
    sleep 1
    expect(join_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
  end
  
  
  # #join should return when broker is killed
  example do
    entry = nil
    message_broker = build_message_broker
    broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    message_broker.expect_received_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.send_message({ 'message_type' => 'compatibility', 'protocol_version' => '0' }.to_json)
    message_broker.expect_received_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    message_broker.send_message({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'null' } }.to_json)
    # --- state: active ---
    join_thread = Thread.new { broker.join }
    broker.kill
    message_broker.expect_received_kill
    expect(join_thread.alive?).to be(true)
    message_broker.send_kill
    expect(broker.killed?).to be(true)
    expect(broker.closed?).to be(true)
    sleep 1
    expect(join_thread.alive?).to be(false) # no need to join it
    message_broker.expect_received_nothing
  end
  

end
