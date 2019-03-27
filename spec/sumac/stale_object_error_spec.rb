require 'sumac'

# make sure it exists
describe Sumac::StaleObjectError do

  # should be a subclass of Error
  example do
    expect(Sumac::StaleObjectError < Sumac::Error).to be(true)
  end

  # test default message
  example do
    expect(Sumac::StaleObjectError.new.message).to eq('object has been forgotten, it no longer exists on the remote endpoint')
  end

end
