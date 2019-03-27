require 'sumac'

# make sure it exists
describe Sumac::UnexposedMethodError do

  # should be a subclass of Error
  example do
    expect(Sumac::UnexposedMethodError < Sumac::Error).to be(true)
  end

  # test default message
  example do
    expect(Sumac::UnexposedMethodError.new.message).to eq('method is not defined or has not been exposed')
  end

end
