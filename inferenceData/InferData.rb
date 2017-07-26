module InferData
  
  attr_reader :inference

  def initInferModule
    @inference = Inference.new
  end
  
  public
  def infer(allClasses, className, methodName)
    raise "Not implemented"
  end
  
  def recommend(allClasses)
    raise "Not implemented"
  end

  def infers_str()
    return @inference.types.to_a.to_s
  end

  def values_str()
    str = "["
    @inference.values.each do |value|
      if(!value.nil?)
        str += value.to_s + ","
      end
    end
    if(str.size > 1)
      str.chomp!(",")
    end
    str += "]"
    return str
  end

  def addInfers(inference, force = nil)
    return @inference.addInfers(inference)
  end

end
