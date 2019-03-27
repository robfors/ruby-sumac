require 'sumac'

# make sure it exists
describe Sumac::ClosedMessengerError do

  # should be a subclass of Error
  example do
    expect(Sumac::ClosedMessengerError < Sumac::Error).to be(true)
  end

end
