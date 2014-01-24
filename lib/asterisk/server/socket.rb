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

      puts "WebSocket connection open"

      puts handshake
      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      puts "Sending 'Welcome to asterisk-ami, you connected to #{handshake.path}' to client."
      ws.send "Welcome to asterisk-ami, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      ws.send "Pong: #{msg}"
    }

    t = Thread.new do
      connection = Asterisk::Connection.new(ARGV[2], ARGV[3], ARGV[4])
      connection.events do |data|
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