require_relative "inferable"
require_relative "infer_data"
class SelfInstance
  include Inferable
  attr_reader :value
  def initialize(value)
    initInferableModule()
    @value = value
    addInfer(createInfer(:Class, value))
  end
end