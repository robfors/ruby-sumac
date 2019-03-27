require 'sumac'

# make sure it exists
describe Sumac::Objects::LocalReferences do

  def build_local_references
    connection = instance_double('Sumac::Connection')
    id_allocator = instance_double('Sumac::IDAllocator')
    expect(Sumac::IDAllocator).to receive(:new).with(no_args).and_return(id_allocator)
    references = Sumac::Objects::LocalReferences.new(connection)
  end

  # #new
  example do
    connection = instance_double('Sumac::Connection')
    id_allocator = instance_double('Sumac::IDAllocator')
    expect(Sumac::IDAllocator).to receive(:new).with(no_args).and_return(id_allocator)
    references = Sumac::Objects::LocalReferences.new(connection)
    expect(references.instance_variable_get(:@connection)).to be(connection)
    expect(references.instance_variable_get(:@id_allocator)).to be(id_allocator)
    expect(references.instance_variable_get(:@id_table)).to be_a(Hash)
    expect(references).to be_a(Sumac::Objects::LocalReferences)
  end

  # #forget
  example do
    references = build_local_references
    reference1 = instance_double('Sumac::Objects::LocalReference')
    reference2 = instance_double('Sumac::Objects::LocalReference')
    references.instance_variable_set(:@id_table, {1 => reference1, 2 => reference2})
    expect(reference2).to receive(:forget)
    expect(reference1).to receive(:forget)
    references.forget
  end

  # #from_object

  # build: true, tentative: false, reference exists
  example do
    references = build_local_references
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(references).to receive(:find_for_object).with(object, tentative: false).and_return(reference)
    expect(references.from_object(object)).to be(reference)
  end

  # build: true, tentative: false, reference does not exist
  example do
    references = build_local_references
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(references).to receive(:find_for_object).with(object, tentative: false).and_return(nil)
    expect(references).to receive(:create_for_object).with(object, tentative: false).and_return(reference)
    expect(references.from_object(object)).to be(reference)
  end

  # build: false, tentative: false, reference exists
  example do
    references = build_local_references
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(references).to receive(:find_for_object).with(object, tentative: false).and_return(reference)
    expect(references.from_object(object, build: false)).to be(reference)
  end

  # build: false, tentative: false, reference does not exist
  example do
    references = build_local_references
    object = double
    expect(references).to receive(:find_for_object).with(object, tentative: false).and_return(nil)
    expect(references.from_object(object, build: false)).to be_nil
  end

  # build: true, tentative: true, reference exists
  example do
    references = build_local_references
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(references).to receive(:find_for_object).with(object, tentative: true).and_return(reference)
    expect(references.from_object(object, tentative: true)).to be(reference)
  end

  # build: true, tentative: true, reference does not exist
  example do
    references = build_local_references
    object = double
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(references).to receive(:find_for_object).with(object, tentative: true).and_return(nil)
    expect(references).to receive(:create_for_object).with(object, tentative: true).and_return(reference)
    expect(references.from_object(object, tentative: true)).to be(reference)
  end

  # #from_properties

  # reference does not exist
  example do
    references = build_local_references
    reference = instance_double('Sumac::Objects::LocalReference')
    references.instance_variable_set(:@id_table, {})
    properties = double
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    expect{ references.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  example do
    references = build_local_references
    reference = instance_double('Sumac::Objects::LocalReference')
    id = 0
    references.instance_variable_set(:@id_table, {id => reference})
    properties = double
    expect(properties).to receive(:id).with(no_args).and_return(id)
    expect(reference).to receive(:accept).with(no_args)
    expect(references.from_properties(properties)).to be(reference)
  end

  # #remove
  example do
    references = build_local_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::LocalReference')
    id2 = 1
    reference2 = instance_double('Sumac::Objects::LocalReference')
    references.instance_variable_set(:@id_table, {id1 => reference1, id2 => reference2})
    expect(reference1).to receive(:id).with(no_args).and_return(id1)
    id_allocator = references.instance_variable_get(:@id_allocator)
    expect(reference1).to receive(:id).with(no_args).and_return(id1)
    expect(id_allocator).to receive(:free).with(id1)
    references.remove(reference1)
    expect(references.instance_variable_get(:@id_table)).to eq({id2 => reference2})
  end

  # #create_for_object

  # tentative
  example do
    references = build_local_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::LocalReference')
    references.instance_variable_set(:@id_table, {id1 => reference1})
    object = double
    id_allocator = references.instance_variable_get(:@id_allocator)
    id2 = 1
    expect(id_allocator).to receive(:allocate).with(no_args).and_return(id2)
    connection = references.instance_variable_get(:@connection)
    reference2 = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::Objects::LocalReference).to receive(:new).with(connection, id: id2, object: object, tentative: true).and_return(reference2)
    expect(references.send(:create_for_object, object, tentative: true)).to be(reference2)
    expect(references.instance_variable_get(:@id_table)).to eq({id1 => reference1, id2 => reference2})
  end

  example do
    references = build_local_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::LocalReference')
    references.instance_variable_set(:@id_table, {id1 => reference1})
    object = double
    id_allocator = references.instance_variable_get(:@id_allocator)
    id2 = 1
    expect(id_allocator).to receive(:allocate).with(no_args).and_return(id2)
    connection = references.instance_variable_get(:@connection)
    reference2 = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::Objects::LocalReference).to receive(:new).with(connection, id: id2, object: object, tentative: false).and_return(reference2)
    expect(references.send(:create_for_object, object, tentative: false)).to be(reference2)
    expect(references.instance_variable_get(:@id_table)).to eq({id1 => reference1, id2 => reference2})
  end

  # #find_for_object

  # tentative: true, reference does not exist
  example do
    references = build_local_references
    object = double
    connection = references.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(Sumac::LocalObject).to receive(:get_reference).with(object_request_broker, object).and_return(nil)
    expect(references.send(:find_for_object, object, tentative: true)).to be_nil
  end

  # tentative: true, reference exists
  example do
    references = build_local_references
    object = double
    connection = references.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::LocalObject).to receive(:get_reference).with(object_request_broker, object).and_return(reference)
    expect(reference).to receive(:tentative).with(no_args)
    expect(references.send(:find_for_object, object, tentative: true)).to be(reference)
  end

  # tentative: false, reference does not exist
  example do
    references = build_local_references
    object = double
    connection = references.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(Sumac::LocalObject).to receive(:get_reference).with(object_request_broker, object).and_return(nil)
    expect(references.send(:find_for_object, object, tentative: false)).to be_nil
  end

  # tentative: false, reference exists
  example do
    references = build_local_references
    object = double
    connection = references.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    reference = instance_double('Sumac::Objects::LocalReference')
    expect(Sumac::LocalObject).to receive(:get_reference).with(object_request_broker, object).and_return(reference)
    expect(reference).to receive(:accept).with(no_args)
    expect(references.send(:find_for_object, object, tentative: false)).to be(reference)
  end

end
