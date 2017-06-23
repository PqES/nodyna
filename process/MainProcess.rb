#require 'sexp_processor'
class MainProcess < SexpInterpreter
  
  def initialize
    super
    self.default_method = "process_nothing"
    @currentClass = nil
    @methodProcess = MethodProcess.new
  end
  
  def initProcess(ast)
    @classes = {}
    process(ast)
    return @classes
  end
  
  def process_nothing(exp)
  end
  
  def process_class(exp)
    _, className, *args = exp
    clazz = ClassDefinition.new(className)
    puts "Classe #{clazz.name} criada"
    @currentClass = clazz
    @classes[clazz.name] = clazz
    args.map {|subTree| process(subTree) if subTree.class == Sexp}
    @currrentClass = nil
  end
  
  def process_defn(exp)
    if(!@currentClass.nil?)
      method = @methodProcess.initProcess(exp, @currentClass)
      @currentClass.addMethod(method)
    else
      puts "sem classe para processar"
    end
  end
end