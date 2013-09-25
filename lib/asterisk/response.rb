module Asterisk
  class Response
    def self.parse(str)
      parse_lines(str)
    end
  end
end