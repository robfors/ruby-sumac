require 'sumac'

# make sure it exists
describe Sumac::Expose do

  # should point to LocalObject
  example do
    expect(Sumac::Expose).to be(Sumac::LocalObject)
  end

end
