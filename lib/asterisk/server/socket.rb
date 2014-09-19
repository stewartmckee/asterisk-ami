# # Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# # Lincense: New BSD Lincense

# $LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/../lib"
# require File.expand_path(File.dirname(__FILE__)) + "/../../ami"

# Thread.abort_on_exception = true


# if ARGV.size != 5
#   $stderr.puts("Usage: ruby sample/echo_server.rb AMI_USERNAME AMI_PASSWORD AMI_HOSTNAME ACCEPTED_DOMAIN PORT ")
#   exit(1)
# end

# channel = EM::Channel.new

# server = WebSocketServer.new(
#   :accepted_domains => [ARGV[0]],
#   :port => ARGV[1].to_i())

# ami_username = ARGV[2]
# ami_password = ARGV[3]
# ami_host = ARGV[4]

# connection = Asterisk::Connection.new(ARGV[2], ARGV[3], ARGV[4], channel)

# puts("Server is running at port %d" % server.port)
# server.run() do |ws|
#   puts("Connection accepted")
#   puts("Path: #{ws.path}, Origin: #{ws.origin}")
#   if ws.path == "/"
#     puts "Received connection from browser"
#     ws.handshake()
#     ws.send("Connected.")

#     channel.subscribe do |data|
#       if ws
#         puts "Sending #{data[:event]} event to websocket"
#         begin
#           ws.send(data.to_json)
#         rescue => e
#           puts "Error in connection to Browser: #{e.message}"
#           ws = nil
#         end
#       end
#     end
#     while true; end
#     puts "out of loop, finished thread."
#   else
#     ws.handshake("404 Not Found")
#   end
#   puts("Connection closed")
# end