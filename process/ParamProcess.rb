#require 'sexp_processor'
class ParamProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast)
    @params = []
    process(ast)
    return @params
  end
  
  def process_nothing(exp)
    
  end
  
  def process_args(exp)
    _, *args = exp
    args.each do |arg|
      if(arg.class == Symbol)
        @params << (VarDefinition.new(@relatedFile, exp, arg))
      else
        #puts "argumento nao eh symbol, mas sim #{arg.class}"
      end
    end
  end
end
