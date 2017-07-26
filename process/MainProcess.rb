#require 'sexp_processor'
class MainProcess < BasicProcess
  
  def initialize(relatedFile)
    super(relatedFile)
  end
  
  def initProcess(allClasses, ast)
    @allClasses = allClasses
    ClassProcess.new(@relatedFile).initProcess(@allClasses, ast)
    return @allClasses
  end
end
