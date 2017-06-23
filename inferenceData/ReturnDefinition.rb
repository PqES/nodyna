class ReturnDefinition
  include InferData
  
  def initialize(statement)
    @statement = statement
  end
  
  def infer(allClasses, className, methodName)
    if(allClasses.has_key?(className) && allClasses[className].methods.has_key?(methodName))
      types, values, newInfers = @statement.infer(allClasses, className, methodName)
      method = allClasses[className].methods[methodName]
      newInfers = newInfers || method.addInfers(types, values)
      return types, values, newInfers  
    else
      return Set.new, Set.new, false
    end
  end
  
  def to_s
    return @statement.to_s
  end
  
  def recommend(allClasses, className, methodName)
    @statement.recommend(allClasses, className, methodName)
  end
end