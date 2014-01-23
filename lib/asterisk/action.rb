require File.expand_path(File.dirname(__FILE__)) + "/message_helper"

module Asterisk
  class Action
    include Asterisk::MessageHelper

    def initialize(command, options={})
      @command = command
      @options = options
      @options[:action_id] = Random.rand(9999) unless @options.has_key?(:action_id)
    end

    def self.parse(str)
      hash = self.parse_lines(str)
      Asterisk::Action.new(hash.delete(:action), hash)
    end

    # send the ami action
    def send(connection)
      #puts self.to_ami
      connection.write(self.to_ami)
      #connection.waitfor("Match" => /\r\n\r\n/) do |received_data|
        #puts received_data
      #end
    end

    # convert the action to ami string to send down wire
    def to_ami
      ami_lines(@command, @options) + "\r\n\r\n"
    end

    def to_hash
      {:action => @command}.merge(@options)
    end

  end
end