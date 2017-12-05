require_relative "class_process"
require_relative "assignment_process"

class ClassProcess < BasicProcess
  include Singleton

  def initProcess(ast, relatedFile)
    @relatedFile = relatedFile
    @classStack = []
    @currentClass = nil
    process(ast)
  end

  def process_class(exp)

  end

  def process_module(exp)
    process_class(exp)
  end

  def processMethod(exp)
    if(!@currentClass.nil?)
      method = MethodProcess.instance.initProcess(exp, @relatedFile, @currentClass)
      if(method.instanceMethod)
        @currentClass.addInstanceMethod(method)
      else
        @currentClass.addStaticMethod(method)
      end
    end
  end

  def process_defn(exp)
    processMethod(exp)
  end

  def process_defs(exp)
    processMethod(exp)
  end

  def process_call(exp)
    _, _, methodCall = exp
    #if(![:==].include?(methodCall))
    #  linkedFunction, blocks = LinkedFunctionProcess.new(@relatedFile).initProcess(exp, @currentClass.last, @currentClass.last)
    #  @currentClass.last.addStatement(linkedFunction)
    #  blocks.each do |block|
    #    process(block)
    #  end
    #end
  end

  def process_lasgn(exp)
    #varAssignment, blocks = VarAssignmentProcess.new(@relatedFile).initProcess(exp, @currentClass.last,@currentClass.last)
    #if(@currentClass.last.getVariable(varAssignment.var.name).nil?)
    #  @currentClass.last.addVariable(varAssignment.var)
    #end
    #@currentClass.last.addStatement(varAssignment)
    #blocks.each do |block|
    #  process(block)
    #end
  end
end