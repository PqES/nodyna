class ValueDefinition
  include InferData
  
  attr_reader :value
  def initialize(value, isConst = false)
    @value = value
    @isConst = isConst
  end
  
  def infer(allClasses, className, methodName)
    typeInfers = Set.new
    valueInfers = Set.new
    if(@isConst)
      typeInfers << @value.to_s
    else
      typeInfers << @value.class
      valueInfers << @value
    end
    return typeInfers, valueInfers, false
  end
  
  def recommend(allClasses, className, methodName)
    
  end
  
  def to_s
    return "#{value}"
  end
end