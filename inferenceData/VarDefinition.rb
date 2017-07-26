class VarDefinition < BasicDefinition
  include InferData
  attr_reader :name, :inferenceTypes, :inferenceValues
  
  def initialize(relatedFile,relatedExp, name)
    super(relatedFile,relatedExp)
    initInferModule()
    @name = name.to_s
  end
  
  def to_s
    return "#{@name}"
  end
  
  
  def infer(allClasses, className, methodName)
    return false
  end
  
  def recommend(allClasses)

  end
  
  def mergeInfersFromVar(varDefinition)
    if(!varDefinition.nil?)
      newInfers = addInfers(varDefinition.inference)
      return newInfers
    end
    return false
  end
end
