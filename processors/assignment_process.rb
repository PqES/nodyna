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

  def attachVariableInValue(exp, variable)
    if(exp[0] == :if || exp[0] == :case)
      implicitReturns = UtilProcess.getImplicitReturn(exp)
      implicitReturns.each do |implicitReturn|
        value = UtilProcess.processValue(implicitReturn, @relatedFile, @clazz, @method)
        value.addListener(variable) if(!value.nil?)
      end
    else
      value = UtilProcess.processValue(exp, @relatedFile, @clazz, @method)
      value.addListener(variable) if(!value.nil?)
    end
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
    attachVariableInValue(valueToAssign, variable) if !valueToAssign.nil?
  end


  def process_iasgn(exp)
    _, varName, valueToAssign = exp
    variable = @clazz.getInstanceVariableByName(varName)
    if(variable.nil?)
      variable = Variable.new(@relatedFile, exp, exp.line, varName)
      @clazz.addInstanceVariable(variable)
    end
    attachVariableInValue(valueToAssign, variable) if !valueToAssign.nil?
  end

  def process_cvasgn(exp)
    _, varName, valueToAssign = exp
    variable = @clazz.getStaticVariableByName(varName)
    if(variable.nil?)
      variable = Variable.new(@relatedFile, exp, exp.line, varName)
      @clazz.addStaticVariable(variable)
    end
    attachVariableInValue(valueToAssign, variable) if !valueToAssign.nil?
  end
end