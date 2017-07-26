class ReturnDefinition < BasicDefinition
  include InferData
  
  def initialize(relatedFile,relatedExp, statement)
    super(relatedFile,relatedExp)
    initInferModule()
    @statement = statement
  end
  
  def infer(allClasses, className, methodName)
    if(!@statement.nil? && allClasses.has_key?(className) && allClasses[className].methods.has_key?(methodName))
      newInfers = @statement.infer(allClasses, className, methodName)
      method = allClasses[className].methods[methodName]
      newInfers = method.addInfers(@statement.inference) || newInfers
      return newInfers  
    else
      return false
    end
  end
  
  def to_s
    return @statement.to_s
  end
  
  def recommend(allClasses)
    if(!@statement.nil?)
      @statement.recommend(allClasses)
    end
  end
end
