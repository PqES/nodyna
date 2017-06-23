#require 'sexp_processor'
class MethodProcess < SexpInterpreter
  
  def initialize()
    super
    self.default_method = "process_nothing"
    self.warn_on_default = false
    @paramProcess = ParamProcess.new
    @varAssignmentProcess = VarAssignmentProcess.new
    @method = nil
    
  end
  
  def initProcess(ast, clazz)
    @clazz = clazz
    process(ast)
    return @method
  end
  
  def process_nothing(exp)
    exp.each_sexp do |sexp|
      process(sexp)
    end
  end
  
  def process_call(exp)
    _, _, methodCall = exp
    if(![:==].include?(methodCall))
      linkedFunctions = LinkedFunctionProcess.new.initProcess(exp, @clazz, @method)
      puts "[CALL] #{linkedFunctions.to_s}"
      @method.addStatement(linkedFunctions)
    end
  end
  def process_return(exp)
    _, returnExp = exp
    if(returnExp[0] == :str ||returnExp[0] == :lit)
      returnStatement = ReturnDefinition.new(ValueDefinition.new(returnExp[1]))
      puts "[RETURN] Retorno #{returnStatement.to_s} do método #{@method.name} adicionado"
      @method.addReturn(returnStatement);
    elsif(returnExp[0] == :lvar)
      var = @method.getVariable(returnExp[1])
      if(!var.nil?)
        returnStatement = ReturnDefinition.new(var)
        @method.addReturn(returnStatement);
        puts "[RETURN] Retorno #{returnStatement.to_s} do método #{@method.name} adicionado"  
      else
        puts "[ERROR] Retorno de variável não cadastrada!"
      end
    end
  end
  
  def process_defn(exp)
    _, methodName, args, *scope = exp
    params = @paramProcess.initProcess(args)
    @method = MethodDefinition.new(methodName, params)
    puts "[DEFN] Método #{@method.name} criado na classe #{@clazz.name}"
    params.each do |var|
      puts "[PARAM] Parâmetro #{var.name} adicionado no método #{@method.name}"
    end
    scope.map {|subTree| process(subTree) if subTree.class == Sexp}
  end
  
  def process_lasgn(exp)
    varAssignment = VarAssignmentProcess.new.initProcess(exp, @clazz, @method)
    if(@method.getVariable(varAssignment.var.name).nil?)
      @method.addVariable(varAssignment.var)
      puts "[VAR] Variável #{varAssignment.var.name} foi adicionada no método #{@method.name}"
    end
    @method.addStatement(varAssignment)
    puts "[ATTR] Atribuição #{varAssignment.to_s} foi adicionada no método #{@method.name}"
  end
end