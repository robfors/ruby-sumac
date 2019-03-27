require 'sumac'

# make sure it exists
describe Sumac::Objects do

  def build_objects
    connection = instance_double('Sumac::Connection')
    local_references = instance_double('Sumac::Objects::LocalReferences')
    allow(Sumac::Objects::LocalReferences).to receive(:new).with(connection).and_return(local_references)
    remote_references = instance_double('Sumac::Objects::RemoteReferences')
    allow(Sumac::Objects::RemoteReferences).to receive(:new).with(connection).and_return(remote_references)
    objects = Sumac::Objects.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    local_references = instance_double('Sumac::Objects::LocalReferences')
    expect(Sumac::Objects::LocalReferences).to receive(:new).with(connection).and_return(local_references)
    remote_references = instance_double('Sumac::Objects::RemoteReferences')
    expect(Sumac::Objects::RemoteReferences).to receive(:new).with(connection).and_return(remote_references)
    objects = Sumac::Objects.new(connection)
    expect(objects.instance_variable_get(:@connection)).to be(connection)
    expect(objects.instance_variable_get(:@local_references)).to be(local_references)
    expect(objects.instance_variable_get(:@remote_references)).to be(remote_references)
    expect(objects).to be_a(Sumac::Objects)
  end

  # #accept_reference
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:iterate_non_primitives).with(reference).and_yield(reference)
    expect(reference).to receive(:accept)
    objects.accept_reference(reference)
  end

  # #convert_object_to_properties
  example do
    objects = build_objects
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_object_to_reference).with(object).and_return(reference)
    properties = double
    expect(objects).to receive(:convert_reference_to_properties).with(reference).and_return(properties)
    expect(objects.convert_object_to_properties(object)).to be(properties)
  end

  # #convert_object_to_reference

  # build: true, tentative: false, exposed local object
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:iterate_non_primitives).with(object) { |&block| block.call(object) }
    expect(objects).to receive(:exposed_local?).with(object).and_return(true)
    local_references = objects.instance_variable_get(:@local_references)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(local_references).to receive(:from_object).with(object, build: true, tentative: false).and_return(reference)
    expect(objects.convert_object_to_reference(object)).to be(reference)
  end

  # build: false, tentative: false, exposed local object
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:iterate_non_primitives).with(object) { |&block| block.call(object) }
    expect(objects).to receive(:exposed_local?).with(object).and_return(true)
    local_references = objects.instance_variable_get(:@local_references)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(local_references).to receive(:from_object).with(object, build: false, tentative: false).and_return(reference)
    expect(objects.convert_object_to_reference(object, build: false)).to be(reference)
  end

  # build: true, tentative: true, exposed local object
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:iterate_non_primitives).with(object) { |&block| block.call(object) }
    expect(objects).to receive(:exposed_local?).with(object).and_return(true)
    local_references = objects.instance_variable_get(:@local_references)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(local_references).to receive(:from_object).with(object, build: true, tentative: true).and_return(reference)
    expect(objects.convert_object_to_reference(object, tentative: true)).to be(reference)
  end

  # exposed remote object
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:iterate_non_primitives).with(object) { |&block| block.call(object) }
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(true)
    remote_references = objects.instance_variable_get(:@remote_references)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(remote_references).to receive(:from_object).with(object).and_return(reference)
    expect(objects.convert_object_to_reference(object)).to be(reference)
  end

  # #convert_properties_to_object
  example do
    objects = build_objects
    properties = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_properties_to_reference).with(properties).and_return(reference)
    object = double
    expect(objects).to receive(:convert_reference_to_object).with(reference).and_return(object)
    expect(objects.convert_properties_to_object(properties)).to be(object)
  end

  # #convert_properties_to_reference

  # exposed local object
  example do
    objects = build_objects
    properties = double
    expect(objects).to receive(:iterate_non_primitives).with(properties) { |&block| block.call(properties) }
    expect(properties).to receive(:origin).with(no_args).and_return(:local)
    local_references = objects.instance_variable_get(:@local_references)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(local_references).to receive(:from_properties).with(properties).and_return(reference)
    expect(objects.convert_properties_to_reference(properties)).to be(reference)
  end

  # exposed local object does not exist
  example do
    objects = build_objects
    properties = double
    expect(objects).to receive(:iterate_non_primitives).with(properties) { |&block| block.call(properties) }
    expect(properties).to receive(:origin).with(no_args).and_return(:local)
    local_references = objects.instance_variable_get(:@local_references)
    expect(local_references).to receive(:from_properties).with(properties).and_raise(Sumac::ProtocolError)
    expect{ objects.convert_properties_to_reference(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # build: true, tentative: false, exposed remote object
  example do
    objects = build_objects
    properties = double
    expect(objects).to receive(:iterate_non_primitives).with(properties) { |&block| block.call(properties) }
    expect(properties).to receive(:origin).with(no_args).and_return(:remote)
    remote_references = objects.instance_variable_get(:@remote_references)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(remote_references).to receive(:from_properties).with(properties, build: true, tentative: false).and_return(reference)
    expect(objects.convert_properties_to_reference(properties)).to be(reference)
  end

  # build: false, tentative: false, exposed remote object
  example do
    objects = build_objects
    properties = double
    expect(objects).to receive(:iterate_non_primitives).with(properties) { |&block| block.call(properties) }
    expect(properties).to receive(:origin).with(no_args).and_return(:remote)
    remote_references = objects.instance_variable_get(:@remote_references)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(remote_references).to receive(:from_properties).with(properties, build: false, tentative: false).and_return(reference)
    expect(objects.convert_properties_to_reference(properties, build: false)).to be(reference)
  end

  # build: true, tentative: true, exposed remote object
  example do
    objects = build_objects
    properties = double
    expect(objects).to receive(:iterate_non_primitives).with(properties) { |&block| block.call(properties) }
    expect(properties).to receive(:origin).with(no_args).and_return(:remote)
    remote_references = objects.instance_variable_get(:@remote_references)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(remote_references).to receive(:from_properties).with(properties, build: true, tentative: true).and_return(reference)
    expect(objects.convert_properties_to_reference(properties, tentative: true)).to be(reference)
  end

  # #convert_reference_to_object
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:iterate_non_primitives).with(reference) { |&block| block.call(reference) }
    object = double
    expect(reference).to receive(:object).with(no_args).and_return(object)
    expect(objects.convert_reference_to_object(reference)).to be(object)
  end

  # #convert_reference_to_properties
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    properties = reference
    expect(objects.convert_reference_to_properties(reference)).to be(properties)
  end

  # #ensure_sendable

  # max object nesting will not raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    objects = build_objects
    root_object = {'a' => 1}
    allow(objects).to receive(:exposed_local?).and_return(false)
    allow(objects).to receive(:exposed_remote?).and_return(false)
    objects.ensure_sendable(root_object)
  end

  # surpassing max object nesting will raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    objects = build_objects
    root_object = {'a' => {}}
    allow(objects).to receive(:exposed_local?).and_return(false)
    allow(objects).to receive(:exposed_remote?).and_return(false)
    expect{ objects.ensure_sendable(root_object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # exposed_local
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(true)
    objects.ensure_sendable(object)
  end

  # exposed_remote, not sendable
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(true)
    remote_reference = instance_double('Sumac::Objects::RemoteReference')
    expect(objects).to receive(:convert_object_to_reference).with(object).and_return(remote_reference)
    expect(remote_reference).to receive(:sendable?).with(no_args).and_return(false)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::StaleObjectError)
  end

  # exposed_remote, sendable
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(true)
    remote_reference = instance_double('Sumac::Objects::RemoteReference')
    expect(objects).to receive(:convert_object_to_reference).with(object).and_return(remote_reference)
    expect(remote_reference).to receive(:sendable?).with(no_args).and_return(true)
    objects.ensure_sendable(object)
  end

  # nil
  example do
    objects = build_objects
    object = nil
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # false
  example do
    objects = build_objects
    object = false
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # true
  example do
    objects = build_objects
    object = true
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # Exception, message invalid
  example do
    objects = build_objects
    object = instance_double('Exception')
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    allow(object).to receive(:is_a?).with(Exception).and_return(true)
    allow(object).to receive(:message).and_return(1)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # Exception, no message
  example do
    objects = build_objects
    object = instance_double('Exception')
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    allow(object).to receive(:is_a?).with(Exception).and_return(true)
    allow(object).to receive(:message).and_return(nil)
    objects.ensure_sendable(object)
  end

  # Exception, String message
  example do
    objects = build_objects
    object = instance_double('Exception')
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    allow(object).to receive(:is_a?).with(Exception).and_return(true)
    allow(object).to receive(:message).and_return('message_here')
    objects.ensure_sendable(object)
  end

  # Integer
  example do
    objects = build_objects
    object = 1
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # Float
  example do
    objects = build_objects
    object = 1.1
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # String
  example do
    objects = build_objects
    object = 'string'
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # Array, empty
  example do
    objects = build_objects
    object = []
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # Array, element not sendable
  example do
    objects = build_objects
    element = Object.new
    object = [element]
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects).to receive(:exposed_local?).with(element).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(element).and_return(false)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # Array, elements all sendable
  example do
    objects = build_objects
    element = 1
    object = [element]
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects).to receive(:exposed_local?).with(element).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(element).and_return(false)
    objects.ensure_sendable(object)
  end

  # Hash, empty
  example do
    objects = build_objects
    object = {}
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    objects.ensure_sendable(object)
  end

  # Hash, key not sendable
  example do
    objects = build_objects
    key = Object.new
    object = {key => 1}
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects).to receive(:exposed_local?).with(key).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(key).and_return(false)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # Hash, value not sendable
  example do
    objects = build_objects
    key = 'k'
    value = Object.new
    object = {key => value}
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects).to receive(:exposed_local?).with(key).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(key).and_return(false)
    expect(objects).to receive(:exposed_local?).with(value).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(value).and_return(false)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # Hash, keys and values all sendable
  example do
    objects = build_objects
    key = 'k'
    value = 1
    object = {key => value}
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects).to receive(:exposed_local?).with(key).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(key).and_return(false)
    expect(objects).to receive(:exposed_local?).with(value).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(value).and_return(false)
    objects.ensure_sendable(object)
  end

  # other object
  example do
    objects = build_objects
    object = Object.new
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect{ objects.ensure_sendable(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # #exposed?
  
  # local
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(true)
    expect(objects.exposed?(object)).to be(true)
  end

  # remote
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(true)
    expect(objects.exposed?(object)).to be(true)
  end

  # not exposed
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:exposed_local?).with(object).and_return(false)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects.exposed?(object)).to be(false)
  end

  # #exposed_local?

  # not local object
  example do
    objects = build_objects
    object = double
    expect(Sumac::LocalObject).to receive(:local_object?).with(object).and_return(false)
    expect(objects.exposed_local?(object)).to be(false)
  end

  # local object, remote object
  example do
    objects = build_objects
    object = double
    expect(Sumac::LocalObject).to receive(:local_object?).with(object).and_return(true)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(true)
    expect(objects.exposed_local?(object)).to be(false)
  end

  # local object, not remote object
  example do
    objects = build_objects
    object = double
    expect(Sumac::LocalObject).to receive(:local_object?).with(object).and_return(true)
    expect(objects).to receive(:exposed_remote?).with(object).and_return(false)
    expect(objects.exposed_local?(object)).to be(true)
  end

  # #exposed_method?
  example do
    objects = build_objects
    object = double
    method = 'm'
    expect(Sumac::LocalObject).to receive(:exposed_method?).with(object, method).and_return(false)
    expect(objects.exposed_method?(object, method)).to be(false)
  end

  # #exposed_remote?
  example do
    objects = build_objects
    object = double
    connection = objects.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(Sumac::RemoteObject).to receive(:remote_object?).with(object_request_broker, object).and_return(false)
    expect(objects.exposed_remote?(object)).to be(false)
  end

  # #forget
  example do
    objects = build_objects
    local_references = objects.instance_variable_get(:@local_references)
    expect(local_references).to receive(:forget)
    remote_references = objects.instance_variable_get(:@remote_references)
    expect(remote_references).to receive(:forget)
    objects.forget
  end

  # #iterate_non_primitives
  example do
    objects = build_objects
    references = [instance_double('Sumac::Objects::RemoteReference'), instance_double('Sumac::Objects::RemoteReference'), instance_double('Sumac::Objects::RemoteReference')]
    properties = [double(:origin => :remote, :id => 0), double(:origin => :remote, :id => 1), double(:origin => :remote, :id => 2)]
    item_in = [nil, false, true, [1, 'ab', references[0]], Sumac::ArgumentError.new, 1.2, {'cd' => references[1], 2 => []}, 3, 'ef', references[2]]
    block = Proc.new { |sub_item_in| raise unless sub_item_in == references.shift; sub_item_out = properties.shift }
    item_out = [nil, false, true, [1, 'ab', properties[0]], Sumac::ArgumentError.new, 1.2, {'cd' => properties[1], 2 => []}, 3, 'ef', properties[2]]
    expect(objects.iterate_non_primitives(item_in, &block)).to eq(item_out)
  end

  # #process_forget

  # unexposed object
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(nil)
    expect{ objects.process_forget(object, quiet: false) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # exposed object, quiet: false
  example do
    objects = build_objects
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(reference)
    expect(reference).to receive(:local_forget_request).with(quiet: false)
    objects.process_forget(object, quiet: false)
  end

  # exposed object, quiet: true
  example do
    objects = build_objects
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(reference)
    expect(reference).to receive(:local_forget_request).with(quiet: true)
    objects.process_forget(object, quiet: true)
  end

  # #process_forget_message

  # quiet: false
  example do
    objects = build_objects
    message = instance_double('Sumac::Messages::Forget')
    properties = double
    expect(message).to receive(:object).with(no_args).and_return(properties)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_properties_to_reference).with(properties, build: false).and_return(reference)
    expect(reference).to receive(:remote_forget_request).with(quiet: false)
    objects.process_forget_message(message, quiet: false)
  end

  # quiet: true
  example do
    objects = build_objects
    message = instance_double('Sumac::Messages::Forget')
    properties = double
    expect(message).to receive(:object).with(no_args).and_return(properties)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_properties_to_reference).with(properties, build: false).and_return(reference)
    expect(reference).to receive(:remote_forget_request).with(quiet: true)
    objects.process_forget_message(message, quiet: true)
  end

  # #receivable?
  example do
    objects = build_objects
    object = instance_double('Sumac::RemoteObject')
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(reference)
    expect(reference).to receive(:receivable?).with(no_args).and_return(false)
    expect(objects.receivable?(object)).to be(false)
  end

  # #reject_reference
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:iterate_non_primitives).with(reference).and_yield(reference)
    expect(reference).to receive(:reject)
    objects.reject_reference(reference)
  end

  # #remove_reference

  # local reference
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::Objects::LocalReference).to receive(:===).with(reference).and_return(true)
    local_references = objects.instance_variable_get(:@local_references)
    expect(local_references).to receive(:remove).with(reference)
    objects.remove_reference(reference)
  end

  # remote reference
  example do
    objects = build_objects
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::Objects::LocalReference).to receive(:===).with(reference).and_return(false)
    expect(Sumac::Objects::RemoteReference).to receive(:===).with(reference).and_return(true)
    remote_references = objects.instance_variable_get(:@remote_references)
    expect(remote_references).to receive(:remove).with(reference)
    objects.remove_reference(reference)
  end

  # #sendable?

  # not sendable
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:ensure_sendable).with(object).and_raise(Sumac::UnexposedObjectError)
    expect(objects.sendable?(object)).to be(false)
  end

  # sendable
  example do
    objects = build_objects
    object = double
    expect(objects).to receive(:ensure_sendable).with(object)
    expect(objects.sendable?(object)).to be(true)
  end

  # #stale?
  example do
    objects = build_objects
    object = instance_double('Sumac::RemoteObject')
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(reference)
    expect(reference).to receive(:stale?).with(no_args).and_return(false)
    expect(objects.stale?(object)).to be(false)
  end

end
