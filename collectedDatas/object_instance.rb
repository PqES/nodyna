require_relative "inferable"
require_relative "infer_data"
class ObjectInstance
  include Inferable
  attr_reader :value
  def initialize(value)
    initInferableModule()
    @value = value
    addInfer(createInfer(value, :instance))
  end
end