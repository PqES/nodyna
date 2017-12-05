require "singleton"
require_relative "basic_process"
require_relative "util_process"
require_relative "../collectedDatas/variable"
require_relative "../collectedDatas/literal_def"
require_relative "../collectedDatas/array_def"

class VarAssignmentProcess < BasicProcess

  def initProcess(ast, relatedFile, clazz, method)
    @relatedFile = relatedFile
    @clazz = clazz
    @method = method
    process(ast)
  end

  def process_lasgn(exp)
    _, varName, valueToAssign = exp
    variable = @method.getVariableByName(varName)
    if(variable.nil?)
      variable = Variable.new(@relatedFile, exp, exp.line, varName)
      @method.addVariable(variable)
    end
    value = UtilProcess.getValue(valueToAssign, @relatedFile, @clazz, @method)
    if(!value.nil?)
      value.addListener(variable)
    end
  end

  def process_iasgn(exp)
    _, varName, valueToAssign = exp
    variable = @clazz.getInstanceVariableByName(varName)
    if(variable.nil?)
      variable = Variable.new(@relatedFile, exp, exp.line, varName)
      @clazz.addInstanceVariable(variable)
    end
    value = UtilProcess.getValue(valueToAssign, @relatedFile, @clazz, @method)
    if(!value.nil?)
      value.addListener(variable)
    end
  end
end