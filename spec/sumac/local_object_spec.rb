require 'sumac'

# make sure it exists
describe Sumac::LocalObject do

  # local object should be an ExposedObject
  example do
    klass = Class.new { include Sumac::Expose }
    expect(klass < Sumac::ExposedObject).to be(true)
    object = klass.new
    expect(object).to be_a(Sumac::ExposedObject)
  end

  # ::clear_reference
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object_class = Class.new { include Sumac::LocalObject }
    object = instance_double(object_class)
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    references = instance_double('Array')
    expect(object).to receive(:_sumac_local_references).and_return(references)
    expect(references).to receive(:delete).with(object_request_broker)
    Sumac::LocalObject.clear_reference(object_request_broker, object)
  end

  # ::exposed_method?

  # not exposed

  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    method = :m
    methods = []
    expect(Sumac::LocalObject).to receive(:exposed_methods).with(object).and_return(methods)
    expect(Sumac::LocalObject.exposed_method?(object, method)).to be(false)
  end

  # exposed, not implemented

  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    method = 'm'
    methods = [:m]
    expect(Sumac::LocalObject).to receive(:exposed_methods).with(object).and_return(methods)
    expect(Sumac::LocalObject.exposed_method?(object, method)).to be(false)
  end

  # exposed, implemented

  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject; def m; end })
    method = 'm'
    methods = [:m]
    expect(Sumac::LocalObject).to receive(:exposed_methods).with(object).and_return(methods)
    expect(Sumac::LocalObject.exposed_method?(object, method)).to be(false)
  end

  # integration test: check a method that is not implemented or exposed
  # !!! important security test !!!
  example do
    object_class = Class.new { include Sumac::LocalObject }
    object = object_class.new
    expect(Sumac::LocalObject.exposed_method?(object, 'm')).to be(false)
  end

  # integration test: check a method that is implemented but not exposed
  # !!! important security test !!!
  example do
    object_class = Class.new do
      include Sumac::LocalObject
      def m; end
    end
    object = object_class.new
    expect(Sumac::LocalObject.exposed_method?(object, 'm')).to be(false)
  end

  # integration test: check a method that is implemented but not exposed
  # !!! important security test !!!
  example do
    object_class = Class.new do
      include Sumac::LocalObject
      expose_method :m
      def m; end
    end
    object = object_class.new
    expect(Sumac::LocalObject.exposed_method?(object, 'mm')).to be(false)
  end

  # ::exposed_methods

  # not local object
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    expect(Sumac::LocalObject).to receive(:local_object?).with(object).and_return(false)
    expect{ Sumac::LocalObject.exposed_methods(object) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # local object
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    expect(Sumac::LocalObject).to receive(:local_object?).with(object).and_return(true)
    methods = double
    expect(object).to receive(:_sumac_exposed_singleton_methods).with(no_args).and_return(methods)
    expect(Sumac::LocalObject.exposed_methods(object)).to be(methods)
  end

  # integration test: when called with one exposed method it should return the method
  example do
    object_class = Class.new do
      include Sumac::Expose
      expose_method :a
    end
    object = object_class.new
    expect(Sumac::LocalObject.exposed_methods(object)).to eq([:a])
  end

  # ::get_reference

  # no reference set
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    references = {}
    expect(object).to receive(:_sumac_local_references).with(no_args).and_return(references)
    expect(Sumac::LocalObject.get_reference(object_request_broker, object)).to be_nil
  end

  # reference set
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    reference = instance_double('Sumac::Objects::LocalReference')
    references = {object_request_broker => reference}
    expect(object).to receive(:_sumac_local_references).with(no_args).and_return(references)
    expect(Sumac::LocalObject.get_reference(object_request_broker, object)).to be(reference)
  end

  # ::local_object?

  # not local object
  example do
    object = instance_double('Object')
    expect(object).to receive(:respond_to?).with(:_sumac_exposed_singleton_methods).and_return(false)
    expect(Sumac::LocalObject.local_object?(object)).to be(false)
  end

  # local object
  example do
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(object).to receive(:respond_to?).with(:_sumac_exposed_singleton_methods).and_return(true)
    expect(Sumac::LocalObject.local_object?(object)).to be(true)
  end

  # ::set_reference
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double(Class.new { include Sumac::LocalObject })
    expect(Sumac::LocalObject).to receive(:synchronize).with(no_args).and_yield
    references = {}
    expect(object).to receive(:_sumac_local_references).with(no_args).and_return(references)
    reference = instance_double('Sumac::Objects::LocalReference')
    Sumac::LocalObject.set_reference(object_request_broker, object, reference)
    expect(references).to eq({object_request_broker => reference})
  end

end
