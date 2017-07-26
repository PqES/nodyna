#require 'sexp_processor'
class LinkedFunctionProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast, scope, clazz) #scope: Class ou Method
    @scope = scope
    @clazz = clazz
    @linkedFunctions = []
    @root = nil
    @blocks = []
    process(ast)
    return LinkedFunctions.new(@relatedFile, ast, @root, @linkedFunctions), @blocks
  end
  
  def process_nothing(exp)
    
  end
  
  def process_call(exp)
    _, called, methodCalled, *params = exp
    if(called.class == Sexp)
      if(called[0] == :lvar)
        @root = @scope.getVariable(called[1])
      elsif(called[0] == :lit || called[0] == :str)
        @root = LiteralDefinition.new(@relatedFile, called, called[1])
      elsif(called[0] == :const)
        @root = ConstDefinition.new(@relatedFile, called, called[1])
      elsif(called[0] == :self)
        @root = ConstDefinition.new(@relatedFile, called, @clazz.name)
      elsif(called[0] == :array)
        @root = ArrayProcess.new(@relatedFile).initProcess(called, @scope, @clazz)
      elsif(called[0] == :iter)
        @root, @blocks = IterationProcess.new(@relatedFile).initProcess(called, @scope, @clazz)
      elsif(called[0] == :call)
        process(called)
      end
    end
    functionCalled = methodCalled.to_s
    functionParams = []
    params.each do |param|
      if(param[0] == :lvar)
        functionParams << @scope.getVariable(param[1])
      elsif(param[0] == :str || param[0] == :lit)
        value = LiteralDefinition.new(@relatedFile, param, param[1])
        functionParams << value
      elsif(param[0] == :const)
        value = ConstDefinition.new(@relatedFile, param, param[1])
        functionParams << value
      elsif(param[0] == :call)
        value, blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(param, @scope, @clazz)
        functionParams << value
        @blocks.concat(blocks)
      end
    end    
    @linkedFunctions << FunctionCallDefinition.new(@relatedFile, exp, functionCalled, functionParams)
  end
end 
