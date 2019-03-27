require 'sumac'

# make sure it exists
describe Sumac::LocalObject::SingletonMethods do

  # #expose_method
  # functional test
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a, :b, 'c'
    end
    expect(c.exposed_methods).to eq([:a,:b,:c])
    i = c.new
    expect(i.exposed_singleton_methods).to eq([:a,:b,:c])
  end

  # #_sumac_expose_method
  # should be same as #expose_method
  example do
    c = Class.new do
      include Sumac::Expose
      _sumac_expose_method :a
    end
    expect(c.exposed_methods).to eq([:a])
  end

  # #exposed_methods
  # functional test: test priority order
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
    expect(c2.exposed_methods).to eq([:a,:c,:e,:f])
  end

  # #_sumac_exposed_methods
  # should be same as #exposed_methods
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
    end
    expect(c.exposed_methods).to eq([:a])
  end

  # #_sumac_instance_expose_preferences
  example do
    klass = Class.new { include Sumac::Expose }
    preferences1 = klass._sumac_instance_expose_preferences
    preferences2 = klass._sumac_instance_expose_preferences
    expect(preferences1).to be_a(Sumac::LocalObject::ExposePreferences)
    expect(preferences1).to be(preferences2)
  end

  # #unexpose_method
  # functional test
  example do
    c = Class.new do
      include Sumac::Expose
      expose_method :a
      expose_method :b
      unexpose_method :b
      unexpose_method :c
    end
    expect(c.exposed_methods).to eq([:a])
  end

  # #_sumac_unexpose_method
  # should be same as #unexpose_method
  example do
    c = Class.new do
      include Sumac::Expose
      _sumac_unexpose_method :a
    end
    expect(c.exposed_methods).to eq([])
  end

end
