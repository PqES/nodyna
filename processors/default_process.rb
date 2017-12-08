require_relative "linked_function_process"
class DefaultProcess < BasicProcess
  include Singleton

  def initProcess(ast, relatedFile, clazz, method)
    @relatedFile = relatedFile
    @clazz = clazz
    @method = method
    process(ast)
  end

  def process_call(exp)
    UtilProcess.processCall(exp, @relatedFile, @clazz, @method)
  end

end