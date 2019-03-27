require 'sumac'

# make sure it exists
describe Sumac::Messages::Message do

  def build_message
    message = Sumac::Messages::Message.new
  end

  # ::max_json_nesting_depth
  example do
    expect(Sumac::Messages::Message.max_json_nesting_depth).to eq((3 * Sumac::MAX_OBJECT_NESTING_DEPTH) + 3)
  end

  # #to_json

  example do
    message = build_message
    expect(message).to receive(:properties).with(no_args).and_return({ 'a' => 1 })
    expect(message.to_json).to eq('{"a":1}')
  end

  # message at max object nesting depth should not raise error
  example do
    message = build_message
    root_object = {}
    current_object = root_object
    (Sumac::Messages::Message.max_json_nesting_depth - 1).times do
      new_object = {}
      current_object['a'] = new_object
      current_object = new_object
    end
    current_object['a'] = 1
    expect(message).to receive(:properties).with(no_args).and_return(root_object)
    expect(message.to_json).to be_a(String)
  end

  # NaN, Infinity and -Infinity should work (as per RFC 4627)
  example do
    message = build_message
    expect(message).to receive(:properties).with(no_args).and_return({ 'a' => Float::NAN, 'b' => Float::INFINITY, 'c' => -Float::INFINITY})
    expect(message.to_json).to eq('{"a":NaN,"b":Infinity,"c":-Infinity}')
  end

end
