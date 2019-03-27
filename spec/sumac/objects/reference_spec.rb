require 'sumac'

# make sure it exists
describe Sumac::Objects::Reference do

  def build_reference
    connection = instance_double('Sumac::Connection')
    id = 0
    future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(future)
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    reference = Sumac::Objects::Reference.new(connection, id: id)
  end

  # #new

  # tentative
  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(future)
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    reference = Sumac::Objects::Reference.new(connection, id: id, tentative: true)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: true)
    expect(reference.instance_variable_get(:@connection)).to be(connection)
    expect(reference.instance_variable_get(:@forget_request_future)).to be(future)
    expect(reference.instance_variable_get(:@id)).to be(id)
    expect(reference.instance_variable_get(:@scheduler)).to be(scheduler)
    expect(reference).to be_a(Sumac::Objects::Reference)
  end

  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(future)
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    reference = Sumac::Objects::Reference.new(connection, id: id)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: false)
    expect(reference.instance_variable_get(:@connection)).to be(connection)
    expect(reference.instance_variable_get(:@forget_request_future)).to be(future)
    expect(reference.instance_variable_get(:@id)).to be(id)
    expect(reference.instance_variable_get(:@scheduler)).to be(scheduler)
    expect(reference).to be_a(Sumac::Objects::Reference)
  end

  # #accept
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:accept).with(no_args)
    reference.accept
  end

  # #forget
  example do
    reference = build_reference
    expect(reference).to receive(:remote_forget_request).with(quiet: true)
    reference.forget
  end

  # #id
  example do
    reference = build_reference
    expect(reference.id).to eq(reference.instance_variable_get(:@id))
  end

  # #local_forget_request
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:forget_locally).with(quiet: true)
    expect(reference.local_forget_request(quiet: true)).to be(reference.instance_variable_get(:@forget_request_future))
  end

  # #no_longer_receivable
  example do
    reference = build_reference
    connection = reference.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:remove_reference).with(reference)
    future = reference.instance_variable_get(:@forget_request_future)
    expect(future).to receive(:set).with(no_args)
    reference.no_longer_receivable
  end

  # #no_longer_sendable
  example do
    reference = build_reference
    reference.no_longer_sendable
  end

  # #object
  example do
    reference = build_reference
    object = double
    reference.instance_variable_set(:@object, object)
    expect(reference.object).to be(object)
  end

  # #receivable?
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:receivable?).with(no_args).and_return(true)
    expect(reference.receivable?).to be(true)
  end

  # #reject
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:reject).with(no_args)
    reference.reject
  end

  # #remote_forget_request
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:forgoten_remotely).with(quiet: true)
    reference.remote_forget_request(quiet: true)
  end

  # #send_forget_message
  example do
    reference = build_reference
    properties = double
    connection = reference.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_reference_to_properties).with(reference).and_return(properties)
    message = instance_double('Sumac::Messages::Forget')
    expect(Sumac::Messages::Forget).to receive(:build).with(object: properties).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    reference.send_forget_message
  end

  # #sendable?
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:sendable?).with(no_args).and_return(true)
    expect(reference.sendable?).to be(true)
  end

  # #stale?
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:sendable?).with(no_args).and_return(false)
    expect(reference.sendable?).to be(false)
  end

  # #tentative
  example do
    reference = build_reference
    scheduler = reference.instance_variable_get(:@scheduler)
    expect(scheduler).to receive(:tentative).with(no_args)
    reference.tentative
  end

end
