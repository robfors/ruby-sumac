class Sumac
  class Message
    class Object
      class HashTable < Object
      
        def initialize(connection)
          super
          @entries = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'hash_table'
          raise MessageError unless json_structure['entries'].is_a?(::Array)
          @entries = json_structure['entries'].map do |entry|
            raise MessageError unless entry.is_a?(::Hash) && entry.include?('key') && entry.include?('value')
            {
              'key' => Dispatch.from_json_structure(@connection, entry['key']),
              'value' => Dispatch.from_json_structure(@connection, entry['value'])
            }
          end
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object.is_a?(::Hash)
          @entries = native_object.map do |key, value|
            {
              'key' => Dispatch.from_native_object(@connection, key),
              'value' => Dispatch.from_native_object(@connection, value)
            }
          end
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          json_entries = @entries.map do |entry|
            {
              'key' => entry['key'].to_json_structure,
              'value' => entry['value'].to_json_structure
            }
          end
          {
            'message_type' => 'object',
            'object_type' => 'hash_table',
            'entries' => json_entries
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          @entries.map { |entry| [entry['key'].to_native_object, entry['value'].to_native_object] }.to_h
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @entries.each do |entry|
            entry['key'].invert_orgin if entry['key'].respond_to?(:invert_orgin)
            entry['value'].invert_orgin if entry['value'].respond_to?(:invert_orgin)
          end
          nil
        end
        
        private
        
        def setup?
          @entries != nil
        end
        
      end
    end
  end
end
