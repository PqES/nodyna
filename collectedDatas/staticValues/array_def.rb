require_relative "static_values"
require_relative "../../collectedDatas/infers/inference_set"
class ArrayDef < BasicData
  include Inferable
  include StaticValues
  attr_reader :elements

  def initialize(rbfile, line, exp, elements)
    super(rbfile, line, exp)
    initInferableModule()
    @elements = elements
    @elementInfers = InferenceSet.new()
    addInfer(createInfer(:array, :instance))
    @elements.each do |element|
      element.addListener(self)
    end
  end

  #abstract
  def onReceiveNotification(obj)
    newInfers = @elementInfers.addAllInfer(obj.inferenceSet.infers)
    if(newInfers)
      notifyNewInfers()
    end
  end

  #abstract
  def isObjectInsance?()
    return true
  end

  #abstract
  def isSelfInstance?()
    return false
  end


  def infersOnEach
    return @elementInfers.infers
  end

  def printCollectedData()
    return "#{printInferData}"
  end
end