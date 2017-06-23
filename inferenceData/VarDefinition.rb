class VarDefinition
  include InferData
  attr_reader :name, :inferenceTypes, :inferenceValues
  
  def initialize(name)
    @name = name.to_s
    @inferenceTypes = Set.new
    @inferenceValues = Set.new
  end
  
  def to_s
    return "#{@name}"
  end
  
  
  def infer(allClasses, className, methodName)
    return @inferenceTypes, @inferenceValues, false
  end
  
  def recommend(allClasses, className, methodName)

  end
  
  def mergeInfersFromVar(varDefinition)
    newInfers = addInfers(varDefinition.inferenceTypes, varDefinition.inferenceValues)
    return newInfers
  end
  
  def addInfers(typeInfers, valueInfers)
    newTypes = addInferenceTypes(typeInfers)
    newValues = addInferenceValues(valueInfers)
    return newTypes || newValues
  end
  
  def addInferenceTypes(infers)
    oldSize = @inferenceTypes.size
    @inferenceTypes.merge(infers)
    newSize = @inferenceTypes.size
    if(newSize > oldSize) #retorna se teve novas inferências
      return true
    else
      return false
    end
  end
  
  def addInferenceValues(infers)
    oldSize = @inferenceValues.size
    @inferenceValues.merge(infers)
    newSize = @inferenceValues.size
    if(newSize > oldSize) #retorna se teve novas inferências
      return true
    else
      return false
    end
  end
end