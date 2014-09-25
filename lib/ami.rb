Dir[File.dirname(__FILE__) + '/asterisk/*.rb'].each {|file| require file }
require "titleize"

module Asterisk
  module Ami
    class Server

      def initialize(username, password, host="localhost", port=5038)
        @connection = Asterisk::Connection.new(username, password, host, port)
      end

      def connect
        begin
          @connection.connect
          @connected = true
        rescue Exception => ex
          false
        end
      end

      def disconnect
        begin
          @connection.disconnect
          @connected = false
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

      def hangup(channel)
        #Asterisk::Action.new("Hangup", {"Channel" => channel}).send(@connection)
        Asterisk::Action.new("Command", {"Command" => "hangup request #{channel}"}).send(@connection)
      end

      def hold(channel, channel2, timeout=3600)
        Asterisk::Action.new("Park", {"Channel" => channel, "Channel2" => channel2, "Timeout" => timeout}).send(@connection)
      end

      def resume(channel, channel2)
        Asterisk::Action.new("Bridge", {"Channel1" => channel, "Channel2" => channel2})
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
        Asterisk::Action.new("QueueAdd", {"Queue" => queue.to_s, "Interface" => exten, "Penalty" => penalty, "Paused" => paused, "MemberName" => member_name}).send(@connection)
      end

      def queue_pause(exten, queue)
        Asterisk::Action.new("QueuePause", {"Queue" => queue.to_s, "Interface" => exten, "Paused" => true}).send(@connection)
      end

      def queue_resume(exten, queue)
        Asterisk::Action.new("QueuePause", {"Queue" => queue.to_s, "Interface" => exten, "Paused" => false}).send(@connection)
      end

      def queue_remove(exten, queue)
        Asterisk::Action.new("QueueRemove", {"Queue" => queue.to_s, "Interface" => exten}).send(@connection)
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

      def start_recording(channel, filename, options={})
        Asterisk::Action.new("MixMonitor", {"Channel" => channel, "File" => filename}).send(@connection)
      end

      def end_recording(channel)
        Asterisk::Action.new("stop_mix_monitor", {"Channel" => channel}).send(@connection)
      end

      def agi(channel, command)
        Asterisk::Action.new("agi", {"Channel" => channel, "Command" => command}).send(@connection)
      end

      def set_variable(name, value, channel)
        puts Asterisk::Action.new("setvar", {"Channel" => channel, "Variable" => name, "Value" => value}).to_ami
        Asterisk::Action.new("setvar", {"Channel" => channel, "Variable" => name, "Value" => value}).send(@connection)
      end
    end
  end
end
