module Asterisk
  class Response

    include Asterisk::MessageHelper
    def self.parse(str)
      parse_lines(str)
    end
  end
end