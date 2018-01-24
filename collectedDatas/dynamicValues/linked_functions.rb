require_relative "../../collectedDatas/infers/inferable"
require_relative "dynamic_values"
class LinkedFunctions < BasicData
  include Inferable
  include DynamicValues
  attr_reader :root, :functions

  def initialize(rbfile, line, exp, root, functions)
    super(rbfile, line, exp)
    initInferableModule()
    @root = root
    @functions = functions
    if(!@root.nil?)
      @root.addListener(self)
    end
    functions.each do |function|
      function.addListener(self)
    end
  end

  def onReceiveNotification(obj)
    infer()
  end

  def infer()
    if(!@root.nil?)
      infers = @root.infers()
      @functions.each do |func|
        func.infer(infers)
        infers = func.infers()
      end
      addAllInfer(infers)
    end
  end


  def to_s(functionToStop = nil)
    if(@root.nil?)
      str = "?."
    elsif(@root.to_s != "")
      str = "#{@root.to_s}."
    else
      str = ""
    end
    @functions.each do |func|
      if(functionToStop == func)
        break
      end
      str = "#{str}#{func.to_s}."
    end
    str.chop!
    return str
  end

  def printCollectedData(spaces = 0)
    if(!@root.nil?)
      if(@root.to_s != "")
        str = "#{" " * spaces}#{@root.to_s}."
      else
        str = "#{" " * spaces}"
      end
      strInfers = "#{@root.printInferData()}"
    else
      str = "#{" " * spaces}?."
      strInfers = ""
    end
    @functions.each do |func|
      str = "#{str}#{func.printCollectedData}."
      strInfers = "#{strInfers} #{func.printInferData}"
    end
    str.chop!
    strInfers = "#{strInfers}"
    return "#{str} #{strInfers}"
  end

end