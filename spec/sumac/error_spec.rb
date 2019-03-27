require 'sumac'

# make sure it exists
describe Sumac::Error do

  # should be a subclass of Error
  example do
    expect(Sumac::Error < StandardError).to be(true)
  end

end
