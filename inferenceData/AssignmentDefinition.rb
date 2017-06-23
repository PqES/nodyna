class AssignmentDefinition
  include InferData
  attr_reader :var, :value
  
  
  def initialize(var, value)
    @var = var
    @value = value
  end
  
  def infer(allClasses, className, methodName)
    typeInfers, valueInfers, newInfers = @value.infer(allClasses, className, methodName)
    newInfers =  newInfers || @var.addInfers(typeInfers, valueInfers)
    return typeInfers, valueInfers, newInfers
  end
  
  def recommend(allClasses, className, methodName)
    @value.recommend(allClasses, className, methodName)
  end
  
  def to_s
    return "#{@var.to_s} = #{@value.to_s}"
  end
end