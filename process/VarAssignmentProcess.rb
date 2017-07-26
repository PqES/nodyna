#require 'sexp_processor'
class VarAssignmentProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast, scope, clazz)
    @scope = scope
    @clazz = clazz
    @assignment = nil
    @blocks = []
    process(ast)
    return @assignment, @blocks
  end
  
  def process_nothing(exp)
    exp.each_sexp do |sexp|
      process(sexp)
    end
  end
  
  def process_lasgn(exp)
    _, varName, valueToAssign = exp
    var = @scope.getVariable(varName)
    if(var.nil?)
      var = VarDefinition.new(@relatedFile, exp, varName) 
    end
    value = nil
    if(valueToAssign[0] == :lit || valueToAssign[0] == :str)
      value = LiteralDefinition.new(@relatedFile, exp, valueToAssign[1])
    elsif(valueToAssign[0] == :array)
      value = ArrayProcess.new(@relatedFile).initProcess(valueToAssign, @scope, @clazz)
    elsif(valueToAssign[0] == :call)
      value, @blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(valueToAssign, @scope, @clazz)
    elsif(valueToAssign[0] == :iter)
      value, @blocks = IterationProcess.new(@relatedFile).initProcess(valueToAssign, @scope, @clazz)
    end
    @assignment = AssignmentDefinition.new(@relatedFile, exp, var, value)
  end
end
