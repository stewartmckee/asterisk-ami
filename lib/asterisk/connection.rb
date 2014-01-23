module Asterisk
  class Connection

    require "net/telnet"
    require "json"
    require "eventmachine"

    def initialize(username, password, server="localhost", port=5038, channel)
      @server = server
      @port = port
      @username = username
      @password = password
      @channel = channel

      @timeout = 1

      @events = []

      connect
    end

    def connect(force = false)
      raise if @test
      @test = true
      if force || @connection.nil?
        puts "Connecting to #{@server}:#{@port} with user #{@username}"
        #@connection = TCPSocket.new @server, @port

        Thread.new { EM.run  }

        # Catch signals to ensure a clean shutdown of EventMachine
        trap(:INT) { EM.stop }
        trap(:TERM){ EM.stop }

        while not EM.reactor_running?; end

        MessageHandler.setup(@server, @port, @username, @password, @channel)

        EventMachine.connect @server, @port, MessageHandler

        # puts "connected"
        # waitfor(/Asterisk Call Manager\/\d\.\d\.\d\r\n/, :block => false) {|response| puts response }
        # puts "Logging in.."
        # Asterisk::Action.new(:login, :username => @username, :secret => @password).send(@connection)
        # puts "Done."

        # t = Thread.new do
        #   loop do 
        #     sleep @timeout
        #     begin
        #       @connectio
        #       n.write("Ping")
        #       puts "Ping"
        #     rescue Errno::EPIPE => e
        #       puts "Broken Pipe - Reconnecting - #{DateTime.now}"
        #       connect(true)
        #       t.kill
        #     end
        #   end
        # end        
      end
    end

    def events(&block)


      force_connection = false
      if block_given?
        while true
          t = Thread.new do |thread|
            while true
              puts "Waiting for data.."
              begin
                waitfor(/\r\n\r\n/) do |received_data|
                  if received_data
                    received_data.split("\n\n").each do |message|
                      #puts "Processing message..."
                      #puts message
                      begin
                        if message.include?("Event")
                          yield Asterisk::Event.parse(message) if block_given?
                        end
                      rescue Errno::EPIPE => e
                        puts "Error in connection to Asterisk: #{e.message}"
                        puts e.backtrace.join("\n")
                        sleep(4)
                        t.kill
                      rescue => e
                        puts "Exception in Loop: #{e.message}"
                        puts e.backtrace.join("\n")
                        sleep(4)
                        t.kill
                      end
                    end
                  # else
                  #   puts "!! no data"
                  #   @connection.close
                  #   puts "Reconnecting..."
                  #   force_connection = true
                  #   connect(true)
                  #   break
                  end
                end
              rescue => e
                puts "Error from waitfor: #{e.message}"
                puts e.backtrace.join("\n")
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

    def waitfor(match, options={:block=>true,:timeout=>5}, &block)
      data = ""
      puts "Waiting..."
      ttl_start = Time.now
      while true
        begin
          @connection.recv(0)
          while line = @connection.recv(1)
            begin
              data += line
              if data =~ match
                puts "Processing Message..."
                yield data if block_given?
                data = ""
                break
              end
            rescue => e
              puts "Exception in waitfor: #{e.message}"
              puts e.backtrace.join("\n")
            end
          end
        rescue => e
          puts "Connection Dropped: #{e.message}"
          connect(true)
        end
        break unless options[:block]
      end
    end

  end
end