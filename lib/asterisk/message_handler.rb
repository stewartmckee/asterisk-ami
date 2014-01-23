module Asterisk
  class MessageHandler < EventMachine::Connection

    def self.setup(server, port, username, password, channel)
      @@server = server
      @@port = port
      @@username = username
      @@password = password
      @@channel = channel
    end

    def post_init
      puts "EM - Connected"
    end

    def connection_completed
      puts "TCP - Connected"
    end

    def receive_data(data)
      @username = "ami_user"
      @password = "jumping-eleven-brick"

      data.split("\r\n\r\n").each do |message|
        if message =~ /Asterisk Call Manager\/\d\.\d\.\d\r\n/
          puts "logging in"
          action = Asterisk::Action.new(:login, :username => @@username, :secret => @@password)
          send_data action.to_ami
        else
          if message.include?("Event")
            @@channel.push Asterisk::Event.parse(message)
          end
        end
      end
    end

    def unbind
      puts "#{@@server}: #{@@port}"
      puts "-- disconnected from remote server!"
      # puts "-- attempting reconnection"
      # reconnect @@server, @@port # use reconnect, already provided by EventMachine 

    end

  end
end