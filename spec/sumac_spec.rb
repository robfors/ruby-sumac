require 'sumac'

# make sure it exists
describe Sumac do

  # ::MAX_OBJECT_NESTING_DEPTH
  example do
    expect(Sumac::MAX_OBJECT_NESTING_DEPTH).to eq(100)
  end

end
