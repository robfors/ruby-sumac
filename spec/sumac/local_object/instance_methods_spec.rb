require 'sumac'

# make sure it exists
describe Sumac::LocalObject::InstanceMethods do

  # #expose_singleton_method
  # functional test
  example do
    c = Class.new do
      include Sumac::Expose
    end
    i = c.new
    i.expose_singleton_method(:a,:b,'c')
    expect(i.exposed_singleton_methods).to eq([:a,:b,:c])
  end

  # #_sumac_expose_singleton_method
  # should be same as #expose_singleton_method
  example do
    c = Class.new do
      include Sumac::Expose
    end
    i = c.new
    i._sumac_expose_singleton_method(:a)
    expect(i.exposed_singleton_methods).to eq([:a])
  end

  # #exposed_singleton_methods

  # functional test: test priority order of class's instance preferences
  example do
    c1 = Class.new do
      include Sumac::Expose
      expose_method :a
      expose_method :b
      unexpose_method :c
      unexpose_method :d
      expose_method :e
    end
    c2 = Class.new(c1) do
      expose_method :a
      unexpose_method :b
      expose_method :c
      unexpose_method :d
      expose_method :f
    end
    i = c2.new
    expect(i.exposed_singleton_methods).to eq([:a,:c,:e,:f])
  end

  # functional test: test priority of order of singleton preferences over class's instance preferences
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
      expose_method :b
      unexpose_method :c
      unexpose_method :d
      expose_method :e
    end
    i = c.new
    i.expose_singleton_method(:a)
    i.unexpose_singleton_method(:b)
    i.expose_singleton_method(:c)
    i.unexpose_singleton_method(:d)
    i.expose_singleton_method(:f)
    expect(i.exposed_singleton_methods).to eq([:a,:c,:e,:f])
  end

  # #_sumac_exposed_singleton_methods
  # should be same as #exposed_singleton_methods
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
    end
    i = c.new
    expect(i._sumac_exposed_singleton_methods).to eq([:a])
  end

  # #_sumac_local_references
  
  example do
    object = (Class.new { include Sumac::Expose }).new
    expect(object._sumac_local_references).to eq({})
  end

  # integration test: LocalObject::set_reference should be using this
  example do
    object = (Class.new { include Sumac::Expose }).new
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::LocalReference')
    Sumac::LocalObject.set_reference(object_request_broker, object, reference)
    expect(object._sumac_local_references).to eq({object_request_broker => reference})
  end

  # #_sumac_singleton_expose_preferences
  example do
    object = (Class.new { include Sumac::Expose }).new
    preferences1 = object._sumac_singleton_expose_preferences
    preferences2 = object._sumac_singleton_expose_preferences
    expect(preferences1).to be_a(Sumac::LocalObject::ExposePreferences)
    expect(preferences1).to be(preferences2)
  end

  # #unexpose_singleton_method
  # functional test
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
      expose_method :b
      expose_method :c
      expose_method :d
    end
    i = c.new
    i.unexpose_singleton_method(:a,:b,'c')
    expect(i.exposed_singleton_methods).to eq([:d])
  end

  # #_sumac_unexpose_singleton_method
  # should be same as #unexpose_singleton_method
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
      expose_method :b
    end
    i = c.new
    i._sumac_unexpose_singleton_method(:a)
    expect(i.exposed_singleton_methods).to eq([:b])
  end

end
