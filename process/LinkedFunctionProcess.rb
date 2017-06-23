#require 'sexp_processor'
class LinkedFunctionProcess < SexpInterpreter
  
  def initialize
    super
    self.default_method = "process_nothing"
  end
  
  def initProcess(ast, currentClass, currentMethod)
    @linkedFunctions = []
    @root = nil
    @currentClass = currentClass
    @currentMethod = currentMethod
    process(ast)
    return LinkedFunctions.new(@root, @linkedFunctions)
  end
  
  def process_nothing(exp)
    
  end
  
  def process_call(exp)
    _, called, methodCalled, *params = exp
    #puts "called: #{called.to_s}"
    #puts "method called: #{methodCalled.to_s}"
    #puts "params: #{params}"
    if(called.class == Sexp)
      if(called[0] == :lvar)
        @root = @currentMethod.getVariable(called[1])
      elsif(called[0] == :const)
        @root = ValueDefinition.new(called[1], true)
      elsif(called[0] == :call)
        process(called)
      end
    end
    functionCalled = methodCalled.to_s
    functionParams = []
    params.each do |param|
      if(param[0] == :lvar)
        functionParams << @currentMethod.getVariable(param[1])
      elsif(param[0] == :str || param[0] == :lit)
        value = ValueDefinition.new(param[1])
        functionParams << value
      end
    end    
    @linkedFunctions << FunctionCallDefinition.new(functionCalled, functionParams)
  end
end
