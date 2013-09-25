module Asterisk
  class Connection

    def initialize(username, password, server="localhost", port=5038)
      @server = server
      @port = port

      @events = []
    end

    def connect
      @connection = Net::Telnet::new("Host" => @server, "Port" => @port)
      Thread.new(@connection) do |thread|
        server.waitfor("Match" => /\r\n\r\n/) do |received_data|
          if received_data.keys.include?(:response)
            response = Response.parse(received_data)
          else
            event = Event.parse(received_data)
          end
        end
      end

      send(Action.new(:login, :username => @username, :secret => @password)) do |response|

      end

    end

    def disconnect
      @connection.close()
    end

  end
end