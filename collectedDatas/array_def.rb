require_relative "basic_data"
require_relative "inferable"
class ArrayDef < BasicData
  include Inferable
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

  def infersOnEach
    return @elementInfers.infers
  end

  def onReceiveNotification(obj)
    newInfers = @elementInfers.addAllInfer(obj.inferenceSet.infers)
    if(newInfers)
      notifyNewInfers()
    end
  end

  def printCollectedData()
    return "#{printInferData}"
  end
end