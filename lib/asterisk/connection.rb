module Asterisk
  class Connection

    require "net/telnet"
    require "json"
    require "eventmachine"

    def initialize(username, password, server="localhost", port=5038)
      @server = server
      @port = port
      @username = username
      @password = password
      @timeout = 1

      @events = []
      @channel = EM::Channel.new

      connect
    end

    def connect(force = false)
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

      end
    end

    def events(&block)
      @channel.subscribe do |data|
        begin
          yield data
        rescue => e
          puts "Error in connection to Browser: #{e.message}"
        end
      end
      puts "out of loop, finished thread."
    end

    def disconnect
      @connection.close()
    end

    def connection
      @connection
    end

  end
end