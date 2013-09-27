module Asterisk
  class Connection

    require "net/telnet"

    def initialize(username, password, server="localhost", port=5038)
      @server = server
      @port = port
      @username = username
      @password = password

      @events = []
    end

    def connect(&block)
      @connection = Net::Telnet::new("Host" => @server, "Port" => @port, "Timeout" => false, "Telnetmode" => false)
      @connection.waitfor(/Asterisk Call Manager\/\d+\.\d+/) {|response| puts response }
      Action.new(:login, :username => @username, :secret => @password).send(@connection)

      if block_given?
        t = Thread.new do |thread|
          while true
            @connection.waitfor("Match" => /./) do |received_data|
              begin
                if received_data.include?("Response")
                  yield Response.parse(received_data) if block_given?
                else
                  yield Event.parse(received_data) if block_given?
                end
              rescue
                "exception in connection_waitfor"
              end
            end
          end
        end
        t.join
      end
    end

    def disconnect
      @connection.close()
    end

    def connection
      @connection
    end

  end
end