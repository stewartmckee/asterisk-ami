# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/../lib"
require File.expand_path(File.dirname(__FILE__)) + "/ami"
require File.expand_path(File.dirname(__FILE__)) + "/web_socket"

Thread.abort_on_exception = true
# WebSocket.debug = true

if ARGV.size != 2
  $stderr.puts("Usage: ruby sample/echo_server.rb ACCEPTED_DOMAIN PORT")
  exit(1)
end


server = WebSocketServer.new(
  :accepted_domains => [ARGV[0]],
  :port => ARGV[1].to_i())
puts("Server is running at port %d" % server.port)
server.run() do |ws|
  puts("Connection accepted")
  puts("Path: #{ws.path}, Origin: #{ws.origin}")
  if ws.path == "/"
    ws.handshake()
    connection = Asterisk::Connection.new("admin", "amp111", "pbx.caseblocks.com")
    connection.connect do |data|
      puts "Waiting"
      ws.write(data.to_json)
      puts "Sent: ", data.to_json
    end
    puts "out of loop"
  else
    ws.handshake("404 Not Found")
  end
  puts("Connection closed")
end