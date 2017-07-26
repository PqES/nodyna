class StaticDefinition < BasicDefinition
  include InferData
  attr_reader :value

  def initialize(relatedFile,relatedExp, value)
    super(relatedFile,relatedExp)
    initInferModule()
    @value = value
  end
  
  def infer(allClasses, className, methodName)
    return false
  end
  
  def recommend(allClasses)
    
  end

  def eql?(literal)
    if(literal.class == LiteralDefinition)
      return relatedExp.eql?(@relatedExp) && literal.value.eql?(@value)
    end
    return false
  end

  def hash()
    @value.hash
  end
end
