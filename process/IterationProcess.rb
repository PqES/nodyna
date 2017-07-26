#require 'sexp_processor'
class IterationProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(ast, scope, clazz)
    @iterableDefinition = nil
    @scope = scope
    @clazz = clazz
    @args = []
    @iterate = nil
    @blocks = []
    process(ast)
    @iterableDefinition = IterationDefinition.new(@relatedFile, ast, @iterate, @args)
    return @iterableDefinition, @blocks
  end
  
  def process_nothing(exp)
    
  end
  
  def process_args(exp)
    _, *args = exp
    if(args.size > 0)
      args.each do |arg|
        var = @scope.getVariable(arg)
        if(var.nil?)
          var = VarDefinition.new(@relatedFile,exp,arg)
          @scope.addVariable(var)
        end
        @args << var
      end
    end
  end

  def process_call(exp)
    @iterate, blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(exp, @scope, @clazz)
    @blocks.concat(blocks)
  end
 
  def process_iter(exp)
    _, iter, iterableArgs, block = exp
    process(iter)
    if(iterableArgs != 0)
      process(iterableArgs)
    end
    @blocks << block
  end
end
