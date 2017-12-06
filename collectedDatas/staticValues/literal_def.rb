require_relative "../../collectedDatas/infers/inferable"
require_relative "../../collectedDatas/infers/infer_data"
require_relative "static_values"
class LiteralDef < BasicData
  include Inferable
  include StaticValues

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