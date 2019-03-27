require 'sumac'

# make sure it exists
describe Sumac::Objects::RemoteReferences do

  def build_remote_references
    connection = instance_double('Sumac::Connection')
    references = Sumac::Objects::RemoteReferences.new(connection)
  end

  # #new
  example do
    connection = instance_double('Sumac::Connection')
    references = Sumac::Objects::RemoteReferences.new(connection)
    expect(references.instance_variable_get(:@connection)).to be(connection)
    expect(references.instance_variable_get(:@id_table)).to eq({})
    expect(references).to be_a(Sumac::Objects::RemoteReferences)
  end

  # #forget
  example do
    references = build_remote_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::RemoteReference')
    id2 = 1
    reference2 = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id1 => reference1, id2 => reference2})
    expect(reference1).to receive(:forget).with(no_args)
    expect(reference2).to receive(:forget).with(no_args)
    references.forget
  end

  # #from_object
  example do
    references = build_remote_references
    object = double
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(Sumac::RemoteObject).to receive(:get_reference).with(object).and_return(reference)
    expect(references.from_object(object)).to be(reference)
  end

  # #from_properties

  # build: true, tentative: false, reference exists
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(references).to receive(:find_for_id).with(id, tentative: false).and_return(reference)
    expect(references.from_properties(properties)).to be(reference)
  end

  # build: true, tentative: false, reference does not exist
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(references).to receive(:find_for_id).with(id, tentative: false).and_return(nil)
    expect(references).to receive(:create_for_id).with(id, tentative: false).and_return(reference)
    expect(references.from_properties(properties)).to be(reference)
  end

  # build: false, tentative: false, reference exists
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(references).to receive(:find_for_id).with(id, tentative: false).and_return(reference)
    expect(references.from_properties(properties, build: false)).to be(reference)
  end

  # build: false, tentative: false, reference does not exist
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    expect(references).to receive(:find_for_id).with(id, tentative: false).and_return(nil)
    expect(references.from_properties(properties, build: false)).to be_nil
  end

  # build: true, tentative: true, reference exists
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(references).to receive(:find_for_id).with(id, tentative: true).and_return(reference)
    expect(references.from_properties(properties, tentative: true)).to be(reference)
  end

  # build: true, tentative: true, reference does not exist
  example do
    references = build_remote_references
    properties = instance_double('Sumac::Messages::Component::Exposed')
    id = 0
    expect(properties).to receive(:id).with(no_args).and_return(id)
    reference = instance_double('Sumac::Objects::RemoteReference')
    expect(references).to receive(:find_for_id).with(id, tentative: true).and_return(nil)
    expect(references).to receive(:create_for_id).with(id, tentative: true).and_return(reference)
    expect(references.from_properties(properties, tentative: true)).to be(reference)
  end

  # #remove
  example do
    references = build_remote_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::RemoteReference')
    id2 = 1
    reference2 = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id1 => reference1, id2 => reference2})
    expect(reference1).to receive(:id).with(no_args).and_return(id1)
    references.remove(reference1)
    expect(references.instance_variable_get(:@id_table)).to eq({id2 => reference2})
  end

  # #create_for_id

  # tentative
  example do
    references = build_remote_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id1 => reference1})
    id2 = 1
    reference2 = instance_double('Sumac::Objects::RemoteReference')
    connection = references.instance_variable_get(:@connection)
    expect(Sumac::Objects::RemoteReference).to receive(:new).with(connection, id: id2, tentative: true).and_return(reference2)
    expect(references.send(:create_for_id, id2, tentative: true)).to be(reference2)
    expect(references.instance_variable_get(:@id_table)).to eq({id1 => reference1, id2 => reference2})
  end

  example do
    references = build_remote_references
    id1 = 0
    reference1 = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id1 => reference1})
    id2 = 1
    reference2 = instance_double('Sumac::Objects::RemoteReference')
    connection = references.instance_variable_get(:@connection)
    expect(Sumac::Objects::RemoteReference).to receive(:new).with(connection, id: id2, tentative: false).and_return(reference2)
    expect(references.send(:create_for_id, id2, tentative: false)).to be(reference2)
    expect(references.instance_variable_get(:@id_table)).to eq({id1 => reference1, id2 => reference2})
  end

  # #find_for_id

  # tentative: true, reference does not exist
  example do
    references = build_remote_references
    id = 0
    expect(references.send(:find_for_id, id, tentative: true)).to be_nil
  end

  # tentative: true, reference exists
  example do
    references = build_remote_references
    id = 0
    reference = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id => reference})
    expect(reference).to receive(:tentative).with(no_args)
    expect(references.send(:find_for_id, id, tentative: true)).to be(reference)
  end

  # tentative: false, reference does not exist
  example do
    references = build_remote_references
    id = 0
    expect(references.send(:find_for_id, id, tentative: false)).to be_nil
  end

  # tentative: false, reference exists
  example do
    references = build_remote_references
    id = 0
    reference = instance_double('Sumac::Objects::RemoteReference')
    references.instance_variable_set(:@id_table, {id => reference})
    expect(reference).to receive(:accept).with(no_args)
    expect(references.send(:find_for_id, id, tentative: false)).to be(reference)
  end

end
