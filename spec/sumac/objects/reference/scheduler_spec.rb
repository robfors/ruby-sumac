require 'sumac'

# make sure it exists
describe Sumac::Objects::Reference::Scheduler do

  # will will test by setting it to all possible states and sending all possible (valid) directives for each state

  # states (chronological order):
  #   tentative
  #   active
  #   forget_initiated
  #   stale

  # directives (no particular order, just alphabetical):
  #   accept
  #   forget_locally(quiet: false)
  #   forget_locally(quiet: true)
  #   forgoten_remotely(quiet: false)
  #   forgoten_remotely(quiet: true)
  #   reject
  #   tentative


  # #new

  # tentative
  example do
    reference = instance_double('Sumac::Objects::Reference')
    scheduler = Sumac::Objects::Reference::Scheduler.new(reference, tentative: true)
    expect(scheduler.instance_variable_get(:@state)).to eq(:tentative)
    expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(1)
    expect(scheduler).to be_a(Sumac::Objects::LocalReference::Scheduler)
  end

  example do
    reference = instance_double('Sumac::Objects::Reference')
    scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
    expect(scheduler.instance_variable_get(:@state)).to eq(:active)
    expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(0)
    expect(scheduler).to be_a(Sumac::Objects::LocalReference::Scheduler)
  end


  def setup_scheduler(start_state: , end_state: )
    reference = instance_double('Sumac::Objects::Reference')
    case start_state
    when :tentative
      scheduler = Sumac::Objects::Reference::Scheduler.new(reference, tentative: true)
    when :active
      scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
    else
      scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
      scheduler.instance_variable_set(:@state, start_state)
    end
    yield(scheduler, reference)
    expect(scheduler.instance_variable_get(:@state)).to eq(end_state)
  end


  # state: tentative
  # receive: accept
  example do
    setup_scheduler(start_state: :tentative, end_state: :active) do |scheduler, reference|
      scheduler.accept

      expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(0)
    end
  end


  # state: tentative
  # receive: reject
  # conditions: more owners left
  example do
    setup_scheduler(start_state: :tentative, end_state: :tentative) do |scheduler, reference|
      scheduler.instance_variable_set(:@tentative_owners, 2)

      scheduler.reject

      expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(1)
    end
  end


  # state: tentative
  # receive: reject
  # conditions: last owner
  example do
    setup_scheduler(start_state: :tentative, end_state: :stale) do |scheduler, reference|
      expect(reference).to receive(:no_longer_receivable).with(no_args)
      expect(reference).to receive(:no_longer_sendable).with(no_args)

      scheduler.reject

      expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(0)
    end
  end


  # state: tentative
  # receive: tentative
  example do
    setup_scheduler(start_state: :tentative, end_state: :tentative) do |scheduler, reference|
      scheduler.tentative

      expect(scheduler.instance_variable_get(:@tentative_owners)).to eq(2)
    end
  end


  # state: active
  # receive: accept
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, reference|
      scheduler.accept
    end
  end


  # state: active
  # receive: forget_locally(quiet: false)
  example do
    setup_scheduler(start_state: :active, end_state: :forget_initiated) do |scheduler, reference|
      expect(reference).to receive(:send_forget_message).with(no_args)
      expect(reference).to receive(:no_longer_sendable).with(no_args)

      scheduler.forget_locally(quiet: false)
    end
  end


  # state: active
  # receive: forget_locally(quiet: true)
  example do
    setup_scheduler(start_state: :active, end_state: :forget_initiated) do |scheduler, reference|
      expect(reference).to receive(:no_longer_sendable).with(no_args)

      scheduler.forget_locally(quiet: true)
    end
  end


  # state: active
  # receive: forgoten_remotely(quiet: false)
  example do
    setup_scheduler(start_state: :active, end_state: :stale) do |scheduler, reference|
      expect(reference).to receive(:no_longer_receivable).with(no_args)
      expect(reference).to receive(:send_forget_message).with(no_args)
      expect(reference).to receive(:no_longer_sendable).with(no_args)

      scheduler.forgoten_remotely(quiet: false)
    end
  end


  # state: active
  # receive: forgoten_remotely(quiet: true)
  example do
    setup_scheduler(start_state: :active, end_state: :stale) do |scheduler, reference|
      expect(reference).to receive(:no_longer_receivable).with(no_args)
      expect(reference).to receive(:no_longer_sendable).with(no_args)

      scheduler.forgoten_remotely(quiet: true)
    end
  end


  # state: active
  # receive: reject
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, reference|
      scheduler.reject
    end
  end


  # state: active
  # receive: tentative
  example do
    setup_scheduler(start_state: :active, end_state: :active) do |scheduler, reference|
      scheduler.tentative
    end
  end


  # state: forget_initiated
  # receive: accept
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :forget_initiated) do |scheduler, reference|
      scheduler.accept
    end
  end


  # state: forget_initiated
  # receive: forget_locally(quiet: false)
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :forget_initiated) do |scheduler, reference|
      scheduler.forget_locally(quiet: false)
    end
  end


  # state: forget_initiated
  # receive: forget_locally(quiet: true)
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :forget_initiated) do |scheduler, reference|
      scheduler.forget_locally(quiet: true)
    end
  end


  # state: forget_initiated
  # receive: forgoten_remotely(quiet: false)
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :stale) do |scheduler, reference|
      expect(reference).to receive(:no_longer_receivable).with(no_args)

      scheduler.forgoten_remotely(quiet: false)
    end
  end


  # state: forget_initiated
  # receive: forgoten_remotely(quiet: true)
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :stale) do |scheduler, reference|
      expect(reference).to receive(:no_longer_receivable).with(no_args)

      scheduler.forgoten_remotely(quiet: true)
    end
  end


  # state: forget_initiated
  # receive: reject
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :forget_initiated) do |scheduler, reference|
      scheduler.reject
    end
  end


  # state: forget_initiated
  # receive: tentative
  example do
    setup_scheduler(start_state: :forget_initiated, end_state: :forget_initiated) do |scheduler, reference|
      scheduler.tentative
    end
  end


  # state: stale
  # receive: accept
  example do
    setup_scheduler(start_state: :stale, end_state: :stale) do |scheduler, reference|
      scheduler.accept
    end
  end


  # state: stale
  # receive: forget_locally(quiet: false)
  example do
    setup_scheduler(start_state: :stale, end_state: :stale) do |scheduler, reference|
      scheduler.forget_locally(quiet: false)
    end
  end


  # state: stale
  # receive: forget_locally(quiet: true)
  example do
    setup_scheduler(start_state: :stale, end_state: :stale) do |scheduler, reference|
      scheduler.forget_locally(quiet: true)
    end
  end

  # state: stale
  # receive: reject
  example do
    setup_scheduler(start_state: :stale, end_state: :stale) do |scheduler, reference|
      scheduler.reject
    end
  end


  # state: stale
  # receive: tentative
  example do
    setup_scheduler(start_state: :stale, end_state: :stale) do |scheduler, reference|
      scheduler.tentative
    end
  end


  # test: #receivable?, #sendable?, #stale?

  # state: active
  example do
    reference = instance_double('Sumac::Objects::Reference')
    scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
    scheduler.instance_variable_set(:@state, :active)
    expect(scheduler.receivable?).to be(true)
    expect(scheduler.sendable?).to be(true)
    expect(scheduler.stale?).to be(false)
  end

  # state: forget_initiated
  example do
    reference = instance_double('Sumac::Objects::Reference')
    scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
    scheduler.instance_variable_set(:@state, :forget_initiated)
    expect(scheduler.receivable?).to be(true)
    expect(scheduler.sendable?).to be(false)
    expect(scheduler.stale?).to be(false)
  end

  # state: stale
  example do
    reference = instance_double('Sumac::Objects::Reference')
    scheduler = Sumac::Objects::Reference::Scheduler.new(reference)
    scheduler.instance_variable_set(:@state, :stale)
    expect(scheduler.receivable?).to be(false)
    expect(scheduler.sendable?).to be(false)
    expect(scheduler.stale?).to be(true)
  end

end
