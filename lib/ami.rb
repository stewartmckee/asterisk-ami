Dir[File.dirname(__FILE__) + '/asterisk/*.rb'].each {|file| require file }
require "titleize"

puts "Required Asterisk Ami"

module Asterisk
  module Ami
    class Server

      def initialize(username, password, host="localhost", port=5038)
        @connection = Asterisk::Connection.new(username, password, host, port)
      end

      def connect
        begin
          @connection.connect
          self.connected = true
        rescue Exception => ex
          false
        end
      end

      def disconnect
        begin
          @connection.disconnect if self.connected
          self.connected = false
          true
        rescue Exception => ex
          puts ex
          false
        end
      end

      def command(command)
        Asterisk::Action.new("Command", {"Command" => command}).send(@connection)
      end

      def core_show_channels
        Asterisk::Action.new("CoreShowChannels").send(@connection)
      end

      def core_show_channels
        Asterisk::Action.new("Ping").send(@connection)
      end

      def meet_me_list
        Asterisk::Action.new("MeetMeList").send(@connection)
      end

      def parked_calls
        Asterisk::Action.new("ParkedCalls").send(@connection)
      end

      def extension_state(exten,context)
        Asterisk::Action.new("ExtensionState", {"Exten" => exten, "Context" => context}).send(@connection)
      end

      def originate(caller,context,callee,priority,variable=nil)
        Asterisk::Action.new("Originate", {"Channel" => caller, "Context" => context, "Exten" => callee, "Priority" => priority, "Callerid" => caller, "Timeout" => "30000", "Variable" => variable  }).send(@connection)
      end

      def channels
        Asterisk::Action.new("Command", { "Command" => "show channels" }).send(@connection)
      end

      def redirect(caller,context,callee,priority,variable=nil)
        Asterisk::Action.new("Redirect", {"Channel" => caller, "Context" => context, "Exten" => callee, "Priority" => priority, "Callerid" => caller, "Timeout" => "30000", "Variable" => variable}).send(@connection)
      end

      def queues
        Asterisk::Action.new("Queues").send(@connection)
      end

      def queue_add(queue, exten, penalty=2, paused=false, member_name)
        Asterisk::Action.new("QueueAdd", {"Queue" => queue, "Interface" => exten, "Penalty" => penalty, "Paused" => paused, "MemberName" => member_name}).send(@connection)
      end

      def queue_pause(queue, exten)
        Asterisk::Action.new("QueuePause", {"Interface" => exten, "Paused" => paused}).send(@connection)
      end

      def queue_remove(queue, exten)
        Asterisk::Action.new("QueueRemove", {"Queue" => queue, "Interface" => exten}).send(@connection)
      end

      def queue_status
        Asterisk::Action.new("QueueStatus").send(@connection)
      end

      def queue_summary(queue)
        Asterisk::Action.new("QueueSummary", {"Queue" => queue}).send(@connection)
      end

      def mailbox_status(exten, context="default")
        Asterisk::Action.new("MailboxStatus", {"Mailbox" => "#{exten}@#{context}"}).send(@connection)
      end

      def mailbox_count(exten, context="default")
        Asterisk::Action.new("MailboxCount", {"Mailbox" => "#{exten}@#{context}"}).send(@connection)
      end
    end
  end
end
