require_relative "dynamic_values"
require_relative "../../collectedDatas/infers/inferable"
class DynamicString < BasicData
  include Inferable
  include DynamicValues
  attr_reader :elements

  def initialize(rbfile, line, exp, elements)
    super(rbfile, line, exp)
    initInferableModule()
    @elements = elements
    @elements.each do |element|
      element.addListener(self) if !element.nil?
    end
  end



  def generateStrings
    nothingToInfer = false
    infers = []
    currentIndexes = []
    for i in 0..@elements.size-1
      if(@elements[i].nil? || @elements[i].infers.size == 0)
        nothingToInfer = true
        break
      end
      currentIndexes[i] = 0
      infers[i] = @elements[i].infers.to_a
    end
    breakTheWhile = false
    while(!nothingToInfer && !breakTheWhile)
      newStr = ""
      for i in 0..infers.size-1
        newStr = "#{newStr}#{infers[i][currentIndexes[i]].value}"
      end
      @inferenceSet.addInfer(createInfer(newStr.class, newStr))
      indexToIncrement = infers.size - 1
      currentIndexes[indexToIncrement] += 1
      while(currentIndexes[indexToIncrement] == infers[indexToIncrement].size)
        currentIndexes[indexToIncrement] = 0
        indexToIncrement -= 1
        if(indexToIncrement >= 0)
          currentIndexes[indexToIncrement] += 1
        else
          breakTheWhile = true
          break
        end
      end
    end
  end

  #abstract
  def onReceiveNotification(obj)
    generateStrings()
  end

  def to_s
    str = "\""
    @elements.each do |element|
      if (element.class == LiteralDef && element.value.class == String)
        str += element.value
      elsif(!element.nil?)
        str += "\#{#{element.to_s}}"
      else
        str += "\#{?}"
      end
    end
    str += "\""
    return str
  end

  def printCollectedData()
    return "#{to_s} #{printInferData}"
  end
end