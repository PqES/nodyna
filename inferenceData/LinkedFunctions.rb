class LinkedFunctions
  include InferData
  
  def initialize(root, functionsCalled)
    @functions = functionsCalled
    @root = root #var definition
  end
  
  
  def infer(allClasses, className, methodName)
    newInfers = false
    if(!@root.nil?)
      typeInferences, valueInferences, _ = @root.infer(allClasses, className, methodName)
    else
      typeInferences = Set.new
      valueInferences = Set.new
      typeInferences << className
    end
    for i in 0..@functions.count-1
      func = @functions[i]
      if(func.functionName == "new")
        next
      end
      newTypeInferences = Set.new
      newValueInferences = Set.new
      typeInferences.each do |className|
        types, values, tempNewInfers = func.infer(allClasses, className, methodName)
        newTypeInferences.merge(types)
        newValueInferences.merge(values)
        newInfers = newInfers || tempNewInfers
      end
      typeInferences = newTypeInferences
      valueInferences = newValueInferences
    end
    return typeInferences, valueInferences, newInfers
  end
  
  def recommend(allClasses, className, methodName)
    if(!@root.nil?)
      typeInferences,  _ = @root.infer(allClasses, className, methodName)
    else
      typeInferences = Set.new
      typeInferences << className
    end
    for i in 0..@functions.count-1
      func = @functions[i]
      if(func.functionName == "new")
        next
      elsif(func.functionName == "send")
        Recommendation.recommendSend(allClasses, className, methodName, typeInferences, func)
        break
      elsif(func.functionName == "const_get")
        Recommendation.recommendConstGet(allClasses, className, methodName, typeInferences, func)
        break
      elsif(func.functionName == "const_set")
        Recommendation.recommendConstSet(allClasses, className, methodName, typeInferences, func)
        break
      end
      newTypeInferences = Set.new
      newValueInferences = Set.new
      typeInferences.each do |className|
        types, values, tempNewInfers = func.infer(allClasses, className, methodName)
        newTypeInferences.merge(types)
        newValueInferences.merge(values)
        newInfers = newInfers || tempNewInfers
      end
      typeInferences = newTypeInferences
      valueInferences = newValueInferences
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
    return str.chop #chop => remove último carácter da string
  end
end