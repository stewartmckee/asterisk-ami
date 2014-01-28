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

    def connect(force = false)
      if force || @connection.nil?
        puts "Connecting to #{@server}:#{@port} with user #{@username}"
        @connection = Net::Telnet::new("Host" => @server, "Port" => @port, "Timeout" => false, "Telnetmode" => false)
        puts "connected"
        @connection.waitfor(/Asterisk Call Manager\/\d+\.\d+/) {|response| puts response }
        puts "Logging in.."
        Asterisk::Action.new(:login, :username => @username, :secret => @password).send(self)
        puts "Done."
      end
    end

    def write(command)
      @connection.write(command + "\r\n\r\n")
    end

    def events(&block)
      force_connection = false
      if block_given?
        while true
          connect(true)
          t = Thread.new do |thread|
            while true
              puts "Waiting for data.."
              @connection.waitfor("Match" => /\r\n\r\n/) do |received_data|
                if received_data
                  received_data.split("\r\n\r\n").each do |message|
                    begin
                      if message.include?("Event")
                        yield Asterisk::Event.parse(message) if block_given?
                      else
                        puts message
                      end
                    rescue Errno::EPIPE => e
                      puts "Error in connection to Asterisk: #{e.message}"
                      puts e.backtrace.join("\n")
                      sleep(4)
                      t.kill
                    rescue => e
                      puts "Exception in Loop: #{e.message}"
                    end
                  end
                else
                  @connection.close
                  puts "Reconnecting..."
                  force_connection = true
                  connect(true)
                  break
                end
              end
              puts "outside waitfor loop"
            end
            puts "Exited AMI loop!"
          end
          t.join
          puts "after thread join"
        end
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