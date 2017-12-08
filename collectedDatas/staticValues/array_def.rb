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

  def addElement(e)
    @elements << e
    e.addListener(self)
  end

  #abstract
  def onReceiveNotification(obj)
    newInfers = @elementInfers.addAllInfer(obj.infers)
    if(newInfers)
      notifyNewInfers()
    end
  end

  def infersOnEach
    return @elementInfers.infers
  end

  def to_s
    str = "["
    if(@elements.size > 0)
      @elements.each do |element|
        if(!element.nil?)
            str += "#{element.to_s},"
        else
          str += "?,"
        end
      end
      str.chop!
    end
    str += "]"
  end
  def printCollectedData()
    return "#{printInferData}"
  end
end