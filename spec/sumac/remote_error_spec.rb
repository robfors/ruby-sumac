require 'sumac'

# make sure it exists
describe Sumac::RemoteError do

  # ::new
  example do
    error = Sumac::RemoteError.new('TypeError', 'wrong type')
    expect(error.instance_variable_get(:@remote_type)).to eq('TypeError')
    expect(error.instance_variable_get(:@remote_message)).to eq('wrong type')
    expect(error).to be_a(Sumac::RemoteError)
  end

  # #message
  example do
    error = Sumac::RemoteError.new('TypeError', 'wrong type')
    expect(error.message).to eq('TypeError -> wrong type')
  end

  # #remote_message
  example do
    error = Sumac::RemoteError.new('TypeError', 'wrong type')
    expect(error.remote_message).to eq('wrong type')
  end

  # #remote_type
  example do
    error = Sumac::RemoteError.new('TypeError', 'wrong type')
    expect(error.remote_type).to eq('TypeError')
  end

end
