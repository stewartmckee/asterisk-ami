module Asterisk
  class Connection

    require "net/telnet"
    require "json"

    def initialize(username, password, server="localhost", port=5038)
      @server = server
      @port = port
      @username = username
      @password = password

      @events = []
    end

    def connect
      @connection = Net::Telnet::new("Host" => @server, "Port" => @port, "Timeout" => false, "Telnetmode" => false)
      @connection.waitfor(/Asterisk Call Manager\/\d+\.\d+/) {|response| puts response }
      Action.new(:login, :username => @username, :secret => @password).send(@connection)
    end

    def events(&block)
      if block_given?
        t = Thread.new do |thread|
          while true
            @connection.waitfor("Match" => /\r\n\r\n/) do |received_data|
              begin
                if received_data.include?("Event")
                  yield Asterisk::Event.parse(received_data) if block_given?
                end
              rescue Errno::EPIPE => e
                t.exit
              rescue => e
                puts "Exception in Loop: #{e.message}"
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