require_relative "../../collectedDatas/infers/inferable"
require_relative "../../collectedDatas/infers/infer_data"
require_relative "static_values"
class ObjectInstance
  include Inferable
  include StaticValues
  attr_reader :value
  def initialize(value)
    initInferableModule()
    @value = value
    addInfer(createInfer(value, :instance))
  end
end