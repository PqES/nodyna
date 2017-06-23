#require 'sexp_processor'
class VarAssignmentProcess < SexpInterpreter
  
  def initialize
    super
    self.default_method = "process_nothing"
  end
  
  def initProcess(ast, currentClass, currentMethod)
    @result = nil
    @currentClass = currentClass
    @currentMethod = currentMethod
    process(ast)
    return @result
  end
  
  def process_nothing(exp)
    
  end
  
  def process_lasgn(exp)
    _, varName, valueToAssign = exp
    var = @currentMethod.getVariable(varName)
    if(var.nil?)
      var = VarDefinition.new(varName) 
    end
    if(valueToAssign[0] != :call)
      value = ValueDefinition.new(valueToAssign[1])
      @result = AssignmentDefinition.new(var, value)
    else
      linkedFunctions = LinkedFunctionProcess.new.initProcess(valueToAssign, @currentClass, @currentMethod)
      @result = AssignmentDefinition.new(var, linkedFunctions)
    end
  end
end