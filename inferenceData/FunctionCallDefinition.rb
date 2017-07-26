class FunctionCallDefinition < BasicDefinition
  include InferData  
  attr_reader :functionName, :params

  def initialize(relatedFile,relatedExp, functionName, params)
    super(relatedFile,relatedExp)
    initInferModule()
    @functionName = functionName.to_s
    @params = params
  end
  
  
  def infer(allClasses, className, methodName, inference)
    newInfers = false
    @params.each do |param|
      if(!param.nil?)
        newInfers = param.infer(allClasses, className, methodName) || newInfers
      end
    end
    newInference = Inference.new
    if(@functionName == "new") 
      inference.values.each do |objDefinition|
        if(objDefinition.class == ConstDefinition)
          newInference.addType(objDefinition.value.to_s)
          newInference.addValue(objDefinition)
        end
      end
      addInfers(newInference)
      return false
    elsif(@functionName == "class")
      inference.values.each do |objDefinition|
        if(objDefinition.class == ConstDefinition)
          newInference.addType("Class")
          newInference.addValue(objDefinition)
        end
      end
      addInfers(newInference)
      return false
    elsif(@functionName == "<<")
      inference.values.each do |objDefinition|
        if(objDefinition.class == ArrayDefinition)
          objDefinition.addValues(@params)
        end
      end
      return false
    elsif(["to_s", "camelize", "downcase"].include?(@functionName))
      inference.values.each do |objDefinition|
        if(objDefinition.class == ValueDefinition && objDefinition.value.respond_to?(@functionName))
           v = ValueDefinition.new(objDefinition.value.send(@functionName))
           newInference.addValue(v)
           newInference.addType(v.value.class)
        end
      end
      addInfers(newInference)
      return false
    elsif(["each", "map", "any?"].include?(@functionName))
      inference.values.each do |objDefinition|
        if(objDefinition.class == ArrayDefinition)
          objDefinition.value.each do |obj|
            newInference.types.merge(obj.inferenceTypes)
            newInference.addValue(obj)
          end
        end
      end
      addInfers(newInference)
      return false
    elsif(allClasses.has_key?(className) && allClasses[className].methods.has_key?(@functionName))
      method = allClasses[className].methods[@functionName]
      newParams = method.mergeParams(@params, allClasses, className, methodName)
      newInfers = method.infer(allClasses,className,methodName) || newParams
      addInfers(method.inference)
      return newInfers
    end
    return newInfers
  end
  
  def recommend(allClasses, inference)
    @params.each do |param|
      if(!param.nil?)
        param.recommend(allClasses)
      end
    end
    if(@functionName == "send")
      Recommendation.recommendSend(allClasses, self)
    elsif(@functionName == "const_get")
      Recommendation.recommendConstGet(allClasses,self, inference)
    elsif(@functionName == "const_set")
      Recommendation.recommendConstSet(allClasses,self, inference)
    end
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
