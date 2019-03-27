require 'sumac'

# make sure it exists
describe Sumac::ArgumentError do

  # should be a subclass of Error
  example do
    expect(Sumac::ArgumentError < Sumac::Error).to be(true)
  end

  # test default message
  example do
    expect(Sumac::ArgumentError.new.message).to eq('wrong number of arguments given')
  end

end
