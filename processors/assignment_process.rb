require "singleton"
require_relative "basic_process"
require_relative "util_process"
require_relative "../collectedDatas/dynamicValues/variable"
require_relative "../collectedDatas/staticValues/literal_def"
require_relative "../collectedDatas/staticValues/array_def"

class VarAssignmentProcess < BasicProcess

  def initProcess(ast, relatedFile, clazz, method)
    @relatedFile = relatedFile
    @clazz = clazz
    @method = method
    process(ast)
  end

  def process_lasgn(exp)
    _, varName, valueToAssign = exp
    if(!@method.nil?)
      variable = @method.getVariableByName(varName)
      variable = Variable.new(@relatedFile, exp, exp.line, varName) if variable.nil?
      @method.addVariable(variable)
    else
      variable = @clazz.getLocalVariableByName(varName)
      variable = Variable.new(@relatedFile, exp, exp.line, varName) if variable.nil?
      @clazz.addLocalVariable(variable)
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

  def process_cvasgn(exp)
    _, varName, valueToAssign = exp
    variable = @clazz.getStaticVariableByName(varName)
    if(variable.nil?)
      variable = Variable.new(@relatedFile, exp, exp.line, varName)
      @clazz.addStaticVariable(variable)
    end
    value = UtilProcess.getValue(valueToAssign, @relatedFile, @clazz, @method)
    if(!value.nil?)
      value.addListener(variable)
    end
  end
end