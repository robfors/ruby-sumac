require 'sumac'

# make sure it exists
describe Sumac::ProtocolError do

  # should be a subclass of Error
  example do
    expect(Sumac::ProtocolError < Sumac::Error).to be(true)
  end

end
