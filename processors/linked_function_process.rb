require "singleton"
require_relative "basic_process"
require_relative "util_process"
require_relative "../collectedDatas/staticValues/literal_def"
require_relative "../collectedDatas/dynamicValues/linked_functions"
require_relative "../collectedDatas/dynamicValues/function_called"
require_relative "../collectedDatas/const_call"
require_relative "../collectedDatas/staticValues/object_instance"
require_relative "../collectedDatas/staticValues/self_instance"

class LinkedFunctionProcess < BasicProcess

  def initProcess(ast, relatedFile, clazz, method)
    @relatedFile = relatedFile
    @clazz = clazz
    @method = method
    @functions = []
    if(!method.nil? && method.instanceMethod)
      @root = ObjectInstance.new(clazz.fullName)
    else
      @root = SelfInstance.new(clazz.fullName)
    end
    process(ast)
    linkedFunction = LinkedFunctions.new(relatedFile, ast.line, ast, @root, @functions)
    if(!@method.nil?)
      @method.addStatement(linkedFunction)
    else
      @clazz.addStatement(linkedFunction)
    end
    return linkedFunction
  end

  def processParams(params)
    formalParameters = []
    params.each do |param|
      parameterValue = UtilProcess.getValue(param, @relatedFile, @clazz, @method)
      formalParameters << parameterValue
    end
    return formalParameters
  end

  def process_call(exp)
    _, caller, methodCalled, *params = exp
    func = FunctionCalled.new(@relatedFile, exp.line, exp, methodCalled, processParams(params))
    @functions.insert(0, func)
    if(caller.class == Sexp)
      if([:lit, :str, :array, :lvar, :ivar, :const, :colon2].include?(caller[0]))
        @root = UtilProcess.getValue(caller, @relatedFile, @clazz, @method)
      elsif(caller[0] == :call)
        process(caller)
      end
    end
  end
end 