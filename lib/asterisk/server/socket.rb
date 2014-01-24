# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/../lib"
require File.expand_path(File.dirname(__FILE__)) + "/../../ami"

Thread.abort_on_exception = true
# WebSocket.debug = true

if ARGV.size != 5
  $stderr.puts("Usage: asterisk-ami ACCEPTED_DOMAIN PORT AMI_USERNAME AMI_PASSWORD AMI_HOSTNAME")
  exit(1)
end


server = WebSocketServer.new(
  :accepted_domains => [ARGV[0], "localhost"],
  :port => ARGV[1].to_i())

ami_username = ARGV[2]
ami_password = ARGV[3]
ami_host = ARGV[4]

puts("Server is running at port %d" % server.port)
server.run() do |ws|
  puts("Connection accepted")
  puts("Path: #{ws.path}, Origin: #{ws.origin}")
  if ws.path == "/"
    puts "Received connection from browser"
    ws.handshake()
    ws.send("Connected.")
    connection = Asterisk::Connection.new(ARGV[2], ARGV[3], ARGV[4])
    connection.events do |data|
      puts data.to_json
      ws.send(data.to_json)
    end
    puts "out of loop, finished thread."
  else
    ws.handshake("404 Not Found")
  end
  puts("Connection closed")
end