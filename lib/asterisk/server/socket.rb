# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/../lib"
require File.expand_path(File.dirname(__FILE__)) + "/../../asterisk-ami"

require 'em-websocket'

Thread.abort_on_exception = true
# WebSocket.debug = true

if ARGV.size < 3
  $stderr.puts("Usage: asterisk-ami AMI_USERNAME AMI_PASSWORD AMI_HOSTNAME [ACCEPTED_DOMAIN] [PORT]")
  exit(1)
end



host = ARGV[3]
port = ARGV[4].to_i

ami_host = ARGV[0]
ami_username = ARGV[1]
ami_password = ARGV[2]

host = "0.0.0.0" if host.nil?
port = 8088 if port==0

puts "Starting Server on port #{port}"
EM.run {
  EM::WebSocket.run(:host => host, :port => port) do |ws|
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
            ami_command = Asterisk::Action.new(:originate, :action_id => data["action_id"], :channel => "SIP/#{data["from"]}", :extension => data["to"], :priority => 1, :context => "default")
          when "hangup"
            ami_command = Asterisk::Action.new(:hangup, :action_id => data["action_id"], :channel => data["channel"])  
          when "transfer"
            ami_command = Asterisk::Action.new(:blind_transfer, :action_id => data["action_id"], :channel => data["channel"], :extension => data["to"], :context => "default")

          when "hold"
            if data.has_key?("timeout")
              timeout = data["timeout"].to_s.to_i
            else
              timeout = 60
            end
            ami_command = Asterisk::Action.new(:park, :action_id => data["action_id"], :channel => data["channel"], :channel2 => data["my_channel"], :timeout => (timeout*1000).to_s)
          when "unhold"
            ami_command = Asterisk::Action.new(:bridge, :action_id => data["action_id"], :channel => data["my_channel"], :channel2 => data["remote_channel"], :tone => "yes")
          when "start-recording"
            ami_command = Asterisk::Action.new(:monitor, :action_id => data["action_id"], :channel => data["channel"], :format => "wav", :mix => "true")
          when "stop-recording"
            ami_command = Asterisk::Action.new(:stop_monitor, :action_id => data["action_id"], :channel => data["channel"])
          when "pause-recording"
            ami_command = Asterisk::Action.new(:pause_monitor, :action_id => data["action_id"], :channel => data["channel"])
          when "resume-recording"
            ami_command = Asterisk::Action.new(:unpause_monitor, :action_id => data["action_id"], :channel => data["channel"])
          when "queue-add"
            ami_command = Asterisk::Action.new(:queue_add, :action_id => data["action_id"], :channel => data["channel"])
          when "queue-pause"
            ami_command = Asterisk::Action.new(:queue_pause, :action_id => data["action_id"], :channel => data["channel"])
          when "queue-remove"
            ami_command = Asterisk::Action.new(:queue_remove, :action_id => data["action_id"], :channel => data["channel"])
          when "queues"
            ami_command = Asterisk::Action.new(:queues, :action_id => data["action_id"], :channel => data["channel"])
          when "queue-status"
            ami_command = Asterisk::Action.new(:queue_status, :action_id => data["action_id"], :channel => data["channel"])
          when "get_variable"
            ami_command = Asterisk::Action.new(:get_var, :action_id => data["action_id"], :channel => data["channel"], :variable => data["name"])
          end
          puts ami_command.to_ami
          @connection.send(ami_command)
        else
          ws.send ("No action found to execute, you must supply a command")
        end
      else
        ws.send "Pong: #{msg}"
      end
    }

    @connection = Asterisk::Connection.new(ami_username, ami_password, ami_host)
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