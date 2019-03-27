# module Sumac
#   module Message
#     module Inbound
#       module Object
#         class ExposedChild < Base
        
#           def self.from_properties(connection, properties)
#             raise ProtocolError unless properties.keys.length == 3
#             parent = Object.from_properties(connection, properties['parent'])
#             raise ProtocolError unless parent.is_a?(Object::Exposed)
#             key = json_structure['key']
#             raise ProtocolError unless json_structure['key'].is_a?(::String) || key.is_a?(::Integer)
#             new(connection, parent: parent, key: key)
#           end
          
#           def to_native_object
#             native_parent = @parent.native_object
#             case native_parent
#             when ExposedObject
#               begin
#                 native_child = native_parent.__child__(@key)
#               rescue
#                 # TODO: change error type
#                 raise ProtocolError
#               end
#               # TODO: change error type
#               raise unless native_child.is_a?(ExposedObjectChild)
#             when RemoteObject # !!!!!!!!!!
#               # TODO: look for cached wrappers first
#               native_child = RemoteObjectChild.new(connection, native_parent, @key)
#             end
#             native_child
#           end
        
#         end
#       end
#     end
#   end
# end









# module Sumac
#   module Message
#     module Outbound
#       module Object
#         class ExposedChild < Base

#           def self.from_native_object(connection, native_object)
#             begin
#               LocalObject.parent()
#               native_parent = native_object.__parent__
#             rescue
#               raise MessageError
#             end
#           @parent = Exposed.from_native_object(@connection, native_parent)
#           begin
#             key = native_object.__key__
#           rescue
#             raise MessageError
#           end
#           raise unless key.is_a?(::String) || key.is_a?(::Float) || key.is_a?(::Integer)
#           @key = key
#           nil
#         end
        
#         def to_json_structure
#           raise MessageError unless setup?
#           {
#             'message_type' => 'object',
#             'object_type' => 'exposed_child',
#             'parent' => @parent.to_json_structure,
#             'key' => @key
#           }
#         end
        
#         def to_native_object
#           raise MessageError unless setup?
#           native_parent = @parent.to_native_object
#           case native_parent
#           when ExposedObject
#             begin
#               native_child = native_parent.__child__(@key)
#             rescue
#               raise MessageError
#             end
#             raise unless native_child.is_a?(ExposedObjectChild)
#           when RemoteObject !!!!!
#             native_child = RemoteObjectChild.new(@connection, native_parent, @key)
#           end
#           native_child
#         end
        
#         def invert_orgin
#           @parent.invert_orgin
#         end
        
#         private
        
#         def setup?
#           @parent != nil && @key != nil
#         end
        
#       end
#     end
#   end
# end
