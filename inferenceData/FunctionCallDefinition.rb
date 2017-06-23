class FunctionCallDefinition
  include InferData
  
  attr_reader :functionName, :params
  def initialize(functionName, params)
    @functionName = functionName.to_s
    @params = params
  end
  
  
  def infer(allClasses, className, methodName)
    typeInferences = Set.new
    valueInferences = Set.new
    newInfers = false
    if(allClasses.has_key?(className) && allClasses[className].methods.has_key?(@functionName))
      method = allClasses[className].methods[@functionName]
      newParams = method.mergeParams(@params, allClasses, className, methodName)
      if(newParams)
        newInfers = true
      end
      typeInferences.merge(method.typeInferences)
      valueInferences.merge(method.valueInferences)
    end
    return typeInferences, valueInferences, newInfers
  end
  
  def recommend(allClasses, className, methodName)

  end
  
  def to_s
    str = "#{functionName}("
    params.each do |param|
      str += "#{param.to_s},"
    end
    if(params.count > 0)
      str.chop!
    end
    str += ")"
    return str
  end
end