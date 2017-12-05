require_relative "inferable"
require_relative "infer_data"
class LiteralDef < BasicData
  include Inferable
  attr_reader :value

  def initialize(rbfile, line, exp, value)
    super(rbfile, line, exp)
    initInferableModule()
    @value = value
    addInfer(createInfer(value.class, value))
  end


  def to_s
    return @value
  end

  def printCollectedData()
    return "#{@value} #{printInferData}"
  end
end