require 'sumac'

# make sure it exists
describe Sumac::ID do

  # ::valid?

  # not an integer
  example do
    expect(Sumac::ID.valid?(1.2)).to be(false)
  end

  # negative
  example do
    expect(Sumac::ID.valid?(-1)).to be(false)
  end

  # valid
  example do
    expect(Sumac::ID.valid?(1)).to be(true)
  end

  # zero
  example do
    expect(Sumac::ID.valid?(0)).to be(true)
  end

end
