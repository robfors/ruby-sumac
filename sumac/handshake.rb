module Sumac
  class Handshake
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @sent = false
      @local_endpoint_responded = false
      @remote_endpoint_responded = false
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @complete = false
    end
    
    def send
      raise if @sent
      @sent = true
      request = Exchange::Request::Handshake.new(@connection)
      request.entry_object = @connection.local_entry
      request_response = request.send
      @connection.close unless request_response.status == 'ok'
      @mutex.synchronize do
        @local_endpoint_responded = true
        response
      end
    end
    
    def complete?
      @complete
    end
    
    def process_remote_request(request)
      raise unless request.is_a?(Exchange::Request::Handshake)
      @mutex.synchronize do
        raise if @remote_endpoint_responded
        @connection.remote_entry = request.entry_object
        @remote_endpoint_responded = true
        response
      end
      request_response = Exchange::Response::Handshake.new(@connection)
      request_response.status = 'ok'
      request_response
    end
    
    def wait_until_complete
      @mutex.synchronize do
        @resource.wait(@mutex) unless complete?
      end
    end
    
    private
    
    def response
      complete if @local_endpoint_responded && @remote_endpoint_responded
    end
    
    def complete
      @resource.broadcast
      @complete = true
    end
    
  end
end
