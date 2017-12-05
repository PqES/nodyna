require_relative "inferable"
class LinkedFunctions < BasicData
  include Inferable
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
    infers = @root.infers()
    @functions.each do |func|
      func.infer(infers)
      infers = func.infers()
    end
    addAllInfer(infers)
  end


  def to_s(functionToStop = nil)
    if(!@root.nil? && @root.class != ObjectInstance)
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
    if(!@root.nil? && @root.class != ObjectInstance)
      str = "#{" " * spaces}#{@root.to_s}."
      strInfers = "#{@root.printInferData()}"
    else
      str = "#{" " * spaces}"
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