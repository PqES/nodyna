#require 'sexp_processor'
class ClassProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(allClasses, ast)
    @allClasses = allClasses
    @currentClass = [allClasses["DefaultClassNodyna"]]
    process(ast)
  end
  
  def process_nothing(exp)
    if(!([:for, :masgn].include?(exp[0])))
      exp.each_sexp do |sexp|
        process(sexp)
      end
    end
  end
  
  def process_class(exp)
    _, className, *args = exp
    className = className.to_s
    if(@allClasses.has_key?(className))
      clazz = @allClasses[className]
    else
      clazz = ClassDefinition.new(@relatedFile, exp, className)
      @allClasses[className] = clazz
    end
    @currentClass.push(clazz)
    args.map {|subTree| process(subTree) if subTree.class == Sexp}
#    @currrentClass = @currentClass.pop()
    @currentClass.pop()
  end
  
  def process_module(exp)
    process_class(exp)
  end

  def process_defn(exp)
    if(!@currentClass.last.nil?)
      method = MethodProcess.new(@relatedFile).initProcess(exp, @currentClass.last)
      @currentClass.last.addInstanceMethod(method)
    end
  end

  def process_defs(exp)
    if(!@currentClass.last.nil?)
      method = MethodProcess.new(@relatedFile).initProcess(exp, @currentClass.last)
      @currentClass.last.addStaticMethod(method)
    end
  end

  def process_call(exp)
    _, _, methodCall = exp
    if(![:==].include?(methodCall))
      linkedFunction, blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(exp, @currentClass.last, @currentClass.last)
      @currentClass.last.addStatement(linkedFunction)
      blocks.each do |block|
        process(block)
      end
    end
  end

  def process_lasgn(exp)
    varAssignment, blocks = VarAssignmentProcess.new(@relatedFile).initProcess(exp, @currentClass.last,@currentClass.last)
    if(@currentClass.last.getVariable(varAssignment.var.name).nil?)
      @currentClass.last.addVariable(varAssignment.var)
    end
    @currentClass.last.addStatement(varAssignment)
    blocks.each do |block|
      process(block)
    end
  end
end
