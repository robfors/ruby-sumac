require 'sumac'

# make sure it exists
describe Sumac::ClosedObjectRequestBrokerError do

  # should be a subclass of Error
  example do
    expect(Sumac::ClosedObjectRequestBrokerError < Sumac::Error).to be(true)
  end

  # test default message
  example do
    expect(Sumac::ClosedObjectRequestBrokerError.new.message).to eq('object request broker has closed')
  end

end
