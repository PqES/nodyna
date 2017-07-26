class LinkedFunctions < BasicDefinition
  include InferData
  
  def initialize(relatedFile,relatedExp, root, functionsCalled)
    super(relatedFile,relatedExp)
    initInferModule()
    @functions = functionsCalled
    @root = root
    @rootInference = Inference.new
  end
  
  def infer(allClasses, className, methodName)
    newInfers = false
    if(!@root.nil?)
      newInfers = @root.infer(allClasses, className, methodName) || newInfers
      @rootInference = @root.inference
    else
      @rootInference.addType(className)
      @rootInference.addValue(ConstDefinition.new(nil,nil,className))
    end
    inference = @rootInference
    @functions.each do |func|
      inference.types.each do |className|
        newInfers = func.infer(allClasses, className, methodName, inference) || newInfers
        inference = func.inference
      end
    end
    newInfers = addInfers(inference) || newInfers
    return newInfers
  end
  
  def recommend(allClasses)
    inference = @rootInference
    @functions.each do |func|
      func.recommend(allClasses, inference)
      inference = func.inference
    end
  end
  
  def to_s
    str = ""
    if(!@root.nil?)
      str ="#{@root}."
    end
    @functions.each do |functionCalled|
      str += "#{functionCalled.to_s}."
    end
    return str.chop
  end
end
