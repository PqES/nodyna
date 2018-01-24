require "ruby_parser"
class ASTGenerator
  def self.generate(path)
    file_content = File.open(path, "rb").read()
    return RubyParser.new.parse(file_content)
  end
end