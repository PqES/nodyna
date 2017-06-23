#require 'ruby_parser'
class ASTGenerator
  class << self
    def generate(path)
      file_content = File.open(path, "rb").read
      return RubyParser.new.parse(file_content)
    end
  end
end