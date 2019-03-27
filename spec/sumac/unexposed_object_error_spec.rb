require 'sumac'

# make sure it exists
describe Sumac::UnexposedObjectError do

  # should be a subclass of Error
  example do
    expect(Sumac::UnexposedObjectError < Sumac::Error).to be(true)
  end

  # test default message
  example do
    expect(Sumac::UnexposedObjectError.new.message).to eq('object has not been exposed, it can not be send to remote endpoint')
  end

end
