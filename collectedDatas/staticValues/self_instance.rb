require_relative "../../collectedDatas/infers/inferable"
require_relative "../../collectedDatas/infers/infer_data"
require_relative "static_values"
class SelfInstance
  include Inferable
  include StaticValues
  attr_reader :value
  def initialize(value)
    initInferableModule()
    @value = value
    addInfer(createInfer(:Class, value))
  end
end