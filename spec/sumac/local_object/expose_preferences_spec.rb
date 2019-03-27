require 'sumac'

# make sure it exists
describe Sumac::LocalObject::ExposePreferences do

  # ::new
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    expect(preferences.instance_variable_get(:@methods)).to eq({})
    expect(preferences).to be_a(Sumac::LocalObject::ExposePreferences)
  end

  # #expose
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    preferences.instance_variable_set(:@methods, {'a' => :expose, 'b' => :unexpose})
    methods = ['a', 'b', 'c']
    expect(preferences).to receive(:parse_method_names).with(methods)
    preferences.expose(methods)
    expect(preferences.instance_variable_get(:@methods)).to eq({'a' => :expose, 'b' => :expose, 'c' => :expose})
  end

  # functional test: when called with a method name it should expose the method
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    preferences.expose([:a])
    expect(preferences.exposed).to eq([:a])
  end

  # #exposed
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    preferences.instance_variable_set(:@methods, {'a' => :expose, 'b' => :unexpose})
    expect(preferences.exposed).to eq([:a])
  end

  # functional test: when called with an exposed and unexposed method it should list only the exposed mehtod
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    preferences.expose([:a])
    preferences.expose([:b])
    preferences.expose([:c])
    preferences.unexpose([:b])
    expect(preferences.exposed).to eq([:a, :c])
  end

  # #merge
  example do
    preferences1 = Sumac::LocalObject::ExposePreferences.new
    preferences1.instance_variable_set(:@methods, {'a' => :expose, 'b' => :expose})
    preferences2 = Sumac::LocalObject::ExposePreferences.new
    preferences2.instance_variable_set(:@methods, {'b' => :unexpose, 'c' => :expose})
    preferences3 = preferences1.merge(preferences2)
    expect(preferences1.instance_variable_get(:@methods) ).to eq({'a' => :expose, 'b' => :expose})
    expect(preferences2.instance_variable_get(:@methods) ).to eq({'b' => :unexpose, 'c' => :expose})
    expect(preferences3.instance_variable_get(:@methods) ).to eq({'a' => :expose, 'b' => :unexpose, 'c' => :expose})
  end

  # #unexpose
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    preferences.instance_variable_set(:@methods, {'a' => :expose, 'b' => :unexpose, 'c' => :expose})
    methods = ['a', 'b']
    expect(preferences).to receive(:parse_method_names).with(methods)
    preferences.unexpose(methods)
    expect(preferences.instance_variable_get(:@methods)).to eq({'a' => :unexpose, 'b' => :unexpose, 'c' => :expose})
  end

  # #parse_method_names
  
  # no methods
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    expect{ preferences.send(:parse_method_names, []) }.to raise_error(ArgumentError)
  end

  # invalid type
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    expect{ preferences.send(:parse_method_names, [1]) }.to raise_error(TypeError)
  end
  
  # correct
  example do
    preferences = Sumac::LocalObject::ExposePreferences.new
    expect( preferences.send(:parse_method_names, [:a, 'b']) ).to eq(['a', 'b'])
  end

end
