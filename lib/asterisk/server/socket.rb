# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/../lib"
require File.expand_path(File.dirname(__FILE__)) + "/../../ami"

require 'em-websocket'

Thread.abort_on_exception = true
# WebSocket.debug = true

if ARGV.size != 5
  $stderr.puts("Usage: asterisk-ami ACCEPTED_DOMAIN PORT AMI_USERNAME AMI_PASSWORD AMI_HOSTNAME")
  exit(1)
end

# server = WebSocketServer.new(
#   :accepted_domains => [ARGV[0], "localhost"],
#   :port => ARGV[1].to_i())

port = ARGV[1].to_i

ami_username = ARGV[2]
ami_password = ARGV[3]
ami_host = ARGV[4]

puts "Starting Server on port #{port}"
EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => port) do |ws|
    ws.onopen { |handshake|

      puts "Websocket connection request received"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Connected."
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"

      if msg.is_json?
        data = JSON.parse(msg)
        if data["command"]
          case data["command"]
          when "initiate-call"
            ami_command = Asterisk::Action.new(:originate, :channel => "SIP/#{data["from"]}", :extension => data["to"], :priority => 1, :context => "default")
          when "hangup"
            ami_command = Asterisk::Action.new(:hangup, :channel => data["channel"])  
          when "transfer"
            ami_command = Asterisk::Action.new(:blind_transfer, :channel => data["channel"], :extension => data["to"], :context => "default")

          when "hold"
            if data.has_key?("timeout")
              timeout = data["timeout"].to_s.to_i
            else
              timeout = 60
            end
            ami_command = Asterisk::Action.new(:park, :channel => data["channel"], :channel2 => data["my_channel"], :timeout => (timeout*1000).to_s)
          when "unhold"
            ami_command = Asterisk::Action.new(:bridge, :channel => data["my_channel"], :channel2 => data["remote_channel"], :tone => "yes")
          when "start-recording"
            ami_command = Asterisk::Action.new(:monitor, :channel => data["channel"], :format => "wav", :mix => "true")
          when "stop-recording"
            ami_command = Asterisk::Action.new(:stop_monitor, :channel => data["channel"])
          when "pause-recording"
            ami_command = Asterisk::Action.new(:pause_monitor, :channel => data["channel"])
          when "resume-recording"
            ami_command = Asterisk::Action.new(:unpause_monitor, :channel => data["channel"])
          when "queue-add"
            ami_command = Asterisk::Action.new(:queue_add, :channel => data["channel"])
          when "queue-pause"
            ami_command = Asterisk::Action.new(:queue_pause, :channel => data["channel"])
          when "queue-remove"
            ami_command = Asterisk::Action.new(:queue_remove, :channel => data["channel"])
          when "queues"
            ami_command = Asterisk::Action.new(:queues, :channel => data["channel"])
          when "queue-status"
            ami_command = Asterisk::Action.new(:queue_status, :channel => data["channel"])
          end
          puts ami_command.to_ami
          ami_command.send(@connection)
        else
          ws.send ("No action found to execute, you must supply a command")
        end
      else
        ws.send "Pong: #{msg}"
      end
    }

    @connection = Asterisk::Connection.new(ARGV[2], ARGV[3], ARGV[4])
    t = Thread.new do
      @connection.events do |data|
        puts " ====  #{data[:event]} ==== "
        puts data.to_json
        ws.send(data.to_json)
      end
    end

  end
}

# puts("Server is running at port %d" % server.port)
# server.run() do |ws|
#   puts("Connection accepted")
#   puts("Path: #{ws.path}, Origin: #{ws.origin}")
#   if ws.path == "/"
#     puts "Received connection from browser"
#     ws.handshake()
#     ws.send("Connected.")
#     connection = Asterisk::Connection.new(ARGV[2], ARGV[3], ARGV[4])
#     connection.events do |data|
#       puts data.to_json
#       ws.send(data.to_json)
#     end
#     puts "out of loop, finished thread."
#   else
#     ws.handshake("404 Not Found")
#   end
#   puts("Connection closed")
# end