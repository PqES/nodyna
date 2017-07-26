class AssignmentDefinition < BasicDefinition
  include InferData
  attr_reader :var, :value
  
  def initialize(relatedFile,relatedExp, var, value)
    super(relatedFile,relatedExp)
    initInferModule()
    @var = var
    @value = value
  end
  
  def infer(allClasses, className, methodName)
    newInfers = false
    if(!@value.nil?)
      newInfers = @value.infer(allClasses, className, methodName)
      addInfers(@value.inference)
      @var.addInfers(@value.inference)
      return newInfers
    end
    return newInfers
  end
  
  def recommend(allClasses)
    if(!@value.nil?)
      @value.recommend(allClasses)
    end
  end
  
  def to_s
    return "#{@var.to_s} = #{@value.to_s}"
  end
end
