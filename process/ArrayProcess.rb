#require 'sexp_processor'
class ArrayProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast, scope, clazz)
    @scope = scope
    @clazz = clazz
    @values = []
    process(ast)
    @arrayDefinition = ArrayDefinition.new(@relatedFile, ast, @values)
    return @arrayDefinition
  end
  
  def process_nothing(exp)
    exp.each_sexp do |sexp|
      process(sexp)
    end
  end

  def process_str(exp)
    _, str = exp
    @values << LiteralDefinition.new(@relatedFile, exp, str)
  end

  def process_lit(exp)
    _, lit = exp
    @values << LiteralDefinition.new(@relatedFile, exp, lit)
  end

  def process_call(exp)
    _, _, methodCall = exp
    if(![:==].include?(methodCall))
      linkedFunctions,_ = LinkedFunctionProcess.new(@relatedFile).initProcess(exp, @scope, @clazz)
      @values << linkedFunctions
    end
  end

  def process_array(exp)
    _, *expValues = exp
    expValues.each do |expValue|
      if(expValue[0] == :array)
        @values << ArrayProcess.new(@relatedFile).initProcess(expValue, @scope, @clazz)
      else
        process(expValue)
      end
    end
  end
end
