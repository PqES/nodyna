#require 'sexp_processor'
class ParamProcess < SexpInterpreter
  
  def initialize()
    super
    self.default_method = "process_nothing"
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
        @params << (VarDefinition.new(arg))
      else
        puts "argumento nao eh symbol, mas sim #{arg.class}"
      end
    end
  end
end