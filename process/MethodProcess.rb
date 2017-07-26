#require 'sexp_processor'
class MethodProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast, clazz)
    @clazz = clazz
    process(ast)
    return @method
  end
  
  def process_nothing(exp)
    if(!([:for, :masgn].include?(exp[0])))
      exp.each_sexp do |sexp|
        process(sexp)
      end
    end
  end
  
  def process_iter(exp)
    _, iterExp = exp
    iterate, blocks = IterationProcess.new(@relatedFile).initProcess(exp, @method, @clazz)
    @method.addStatement(iterate)
    blocks.each do |block|
      if(!block.nil?)
        process(block)
      end
    end
  end

  def process_call(exp)
    _, _, methodCall = exp
    if(![:==].include?(methodCall))
      linkedFunctions, blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(exp, @method, @clazz)
      @method.addStatement(linkedFunctions)
      blocks.each do |block|
        process(block)
      end
    end
  end


  def process_return(exp)
    _, returnExp = exp
    addReturn(returnExp)
  end
  
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

  def process_defn(exp)
    _,methodName, args, *scope = exp
    params = ParamProcess.new(@relatedFile).initProcess(args)
    @method = MethodDefinition.new(@relatedFile, exp, methodName, params)
    scope.map {|subTree| process(subTree) if subTree.class == Sexp}
    ImplicitReturn.check_implicit_return(getLastStm(scope)).each do |implicitReturn|
      addReturn(implicitReturn)
    end
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
end
