require "singleton"
require_relative "basic_process"
require_relative "assignment_process"
require_relative "linked_function_process"
require_relative "../collectedDatas/structures/method_def"
require_relative "../collectedDatas/dynamicValues/variable"
class MethodProcess < BasicProcess

  def initProcess(ast, relatedFile, clazz)
    @relatedFile = relatedFile
    @clazz = clazz
    @method = nil
    process(ast)
    return @method
  end

  def processMethod(exp, methodName, args, scope, instanceMethod)
    @method = MethodDef.new(@relatedFile, exp.line, exp, methodName, instanceMethod)
    processArgs(args)
    scope.map {|subTree| process(subTree) if subTree.class == Sexp}
  end

  def processArgs(exp)
    _, *args = exp
    args.each do |arg|
      if(arg.class == Symbol)
        variable = Variable.new(@relatedFile, exp.line, exp, arg)
        @method.addFormalParameter(variable)
      end
    end
  end

  def process_defn(exp)
    _,methodName, args, *scope = exp
    processMethod(exp, methodName, args, scope, true)
  end

  def process_defs(exp)
    _,_,methodName,args,*scope = exp
    processMethod(exp, methodName, args, scope, false)
  end

  def process_return(exp)
    _, returnExp = exp
    returnValue = UtilProcess.getValue(returnExp, @relatedFile, @clazz, @method)
    if(!returnValue.nil?)
      returnValue.addListener(@method)
    end
  end

  def process_lasgn(exp)
    VarAssignmentProcess.new.initProcess(exp, @relatedFile, @clazz, @method)
  end

  def process_iasgn(exp)
    VarAssignmentProcess.new.initProcess(exp, @relatedFile, @clazz, @method)
  end

  def process_call(exp)
    linkedFunction = LinkedFunctionProcess.new.initProcess(exp, @relatedFile, @clazz, @method)
    @method.addStatement(linkedFunction)
  end

  def process_iter(exp)
    _, caller, argExp, body = exp
    _, *args = argExp
    if(args.size == 1)
      var = Variable.new(@relatedFile, argExp.line, argExp, args[0])
      @method.addVariable(var)
      if(caller[0] == :call)
        linkedFunction = LinkedFunctionProcess.new.initProcess(caller, @relatedFile, @clazz, @method)
        linkedFunction.addListener(var)
      end
    end
    process(body)
  end



=begin
  def addReturn(returnExp)
    if(!returnExp.nil?) #retorna algo
      if(returnExp[0] == :str ||returnExp[0] == :lit)
        returnStatement = ReturnDefinition.new(@relatedFile, returnExp, ValueDefinition.new(returnExp[1]))
        @method.addReturn(returnStatement);
      elsif(returnExp[0] == :lvar)
        var = @method.getVariable(returnExp[1])
        if(!var.nil?)
          returnStatement = ReturnDefinition.new(@relatedFile, returnExp, var)
          @method.addReturn(returnStatement)
        else
          #puts "[ERROR] Retorno de variável não cadastrada!"
        end
      elsif(returnExp[0] == :array)
        returnStatement,_  = ArrayProcess.new(@relatedFile).initProcess(returnExp, @method, @clazz)
        @method.addReturn(returnStatement)
      end
    end
  end

  def getLastStm(exps)
    lastStm = nil
    exps.each do |exp|
      if(exp.class == Sexp)
        lastStm = exp
      end
    end
    return lastStm
  end

  def process_defs(exp)
    _, _,methodName, args, *scope = exp
    params = ParamProcess.new(@relatedFile).initProcess(args)
    @method = MethodDefinition.new(@relatedFile, exp, methodName, params)
    scope.map {|subTree| process(subTree) if subTree.class == Sexp}
  end

  def process_lasgn(exp)
    varAssignment, blocks = VarAssignmentProcess.new(@relatedFile).initProcess(exp, @method, @clazz)
    if(@method.getVariable(varAssignment.var.name).nil?)
      @method.addVariable(varAssignment.var)
    end
    @method.addStatement(varAssignment)
    blocks.each do |block|
      process(block)
    end
  end
=end
end