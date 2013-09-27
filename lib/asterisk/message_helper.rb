module Asterisk
  module MessageHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def parse_lines(str)
        hash = {}
        lines = str.gsub("\r", "").split("\n").select{|line| line.include?(":")}
        lines = lines.map{|line| [line.split(":")[0], line.split(":")[1..-1].join(":")]}
        lines = lines.map{|element| element.map{|e| e.strip}}
        lines = lines.flatten
        if lines.count > 0
          hash = Hash[*lines]
          hash.keys.each do |key|
            hash[(underscore(key).to_sym) || key] = hash.delete(key)
          end
        end
        hash
      end

      def underscore(str)
        str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
    end

    def ami_lines(command, options)
      messages = []
      messages << add_line("Action", camelize(command, :upcase_ids => true))
      options.map{|k,v| messages << add_line(camelize(k, :upcase_ids => true),v) }
      messages.join("\r\n")
    end

    def add_line(key, value)
      "#{key}: #{value}"
    end

    def camelize(term, options={})
      options[:upcase_ids] = false unless options.has_key?(:upcase_ids)

      string = term.to_s
      string.split(/[\s|_]/).map{|s| s[0].upcase + s[1..-1].downcase}.join("")
    end    
  end
end