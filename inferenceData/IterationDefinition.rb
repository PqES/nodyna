class IterationDefinition < BasicDefinition
  include InferData
  attr_reader :iterate, :iterateVars
 
  def initialize(relatedExp, iterate, iterateVars)
    super(relatedExp)
    initInferModule()
    @iterate = iterate
    @iterateVars = iterateVars
  end
  
  def infer(allClasses, className, methodName)
    if(!@iterate.nil? && @iterateVars.size > 0 && !@iterateVars[0].nil?)
      @iterate.infer(allClasses, className, methodName)
      addInfers(@iterate.inferenceTypes, @iterate.inferenceValues)
      newInfers = @iterateVars[0].addInfers(@iterate.inferenceTypes, @iterate.inferenceValues)
      return newInfers
    end
    return false
  end
  
  def recommend(allClasses)
    if(!@iterate.nil? && !@iterateVars.nil?)
      @iterate.recommend(allClasses)
      @iterateVars.each do |vars|
        if(!vars.nil?)
          vars.recommend(allClasses)
        end
      end
    end
  end
  
  def to_s
    str = "#{@iterate.to_s} in |"
    @iterateVars.each do |var|
      str = "#{str} #{var.to_s},"
    end
    if(str.size > 1)
      str.chomp!(',')
    end
    str += "|"
    return str
  end
end
