require_relative "../collectedDatas/const_call"
require_relative "../collectedDatas/dynamicValues/linked_functions"
require_relative "../collectedDatas/staticValues/object_instance"
require_relative "../collectedDatas/staticValues/literal_def"
require_relative "../collectedDatas/staticValues/array_def"
require_relative "../collectedDatas/dynamicValues/dynamic_string"
require_relative "default_process"
class UtilProcess

  def self.processValue(exp, relatedFile, clazz, method)
    return nil if exp.class != Sexp
    value = nil
    if(:lit == exp[0] || :str == exp[0])
      value = self.processLit(exp, relatedFile, clazz, method)
    elsif(:nil == exp[0])
      value = ObjectInstance.new(:NilClass)
    elsif(:array == exp[0])
      value = self.processArray(exp, relatedFile, clazz, method)
    elsif([:lvar, :ivar, :cvar].include?(exp[0]))
      value = self.processVar(exp, relatedFile, clazz, method)
    elsif([:lasgn,:iasgn,:cvasgn].include?(exp[0]))
      value = self.processAssignment(exp, relatedFile, clazz, method)
    elsif(:const == exp[0] || :colon2 == exp[0])
      value = self.processConst(exp, relatedFile, clazz, method)
    elsif(:dstr == exp[0])
      value = self.processDstr(exp, relatedFile, clazz, method)
    elsif(:call == exp[0])
      value = self.processCall(exp, relatedFile, clazz, method)
    else
      DefaultProcess.instance.initProcess(exp, relatedFile, clazz, method)
    end
    if(value.class == ConstCall || value.class == LinkedFunctions)
      if(!method.nil?)
        method.addStatement(value)
      else
        clazz.addStatement(value)
      end
    end
    return value
  end

  def self.processLit(exp, relatedFile, clazz, method)
    return LiteralDef.new(relatedFile, exp, exp.line, exp[1])
  end

  def self.processArray(exp, relatedFile, clazz, method)
    _, *elementsExp = exp
    elements = []
    elementsExp.each do |elementExp|
      elementValue = UtilProcess.processValue(elementExp, relatedFile, clazz, method)
      elements << elementValue if(!elementValue.nil?)
    end
    return ArrayDef.new(relatedFile, exp, exp.line, elements)
  end

  def self.processVar(exp, relatedFile, clazz, method)
    if(exp[0] == :lvar)
      return method.nil? ? clazz.getLocalVariableByName(exp[1]) : method.getVariableByName(exp[1])
    elsif(exp[0] == :ivar)
      return clazz.getInstanceVariableByName(exp[1])
    elsif(exp[0] == :cvar)
      return clazz.getStaticVariableByName(exp[1])
    end
    return nil
  end

  def self.processAssignment(exp, relatedFile, clazz, method)
    VarAssignmentProcess.new.initProcess(exp, relatedFile, clazz, method)
    if(exp[0] == :lasgn)
      return method.nil? ? clazz.getLocalVariableByName(exp[1]) : method.getVariableByName(exp[1])
    elsif(exp[0] == :iasgn)
      return clazz.getInstanceVariableByName(exp[1])
    elsif(exp[0] == :cvasgn)
      return clazz.getStaticVariableByName(exp[1])
    end
    return nil
  end

  def self.processConst(exp, relatedFile, clazz, method)
    names = self.getNamesFromConst(exp)
    return ConstCall.new(relatedFile, exp, exp.line, names, clazz)
  end

  def self.processDstr(exp, relatedFile, clazz, method)
    _, str, *anotherExp = exp
    values = [LiteralDef.new(relatedFile, exp.line, exp, str)]
    anotherExp.each do |e|
      if(e[0] == :evstr)
        values << UtilProcess.processValue(e[1], relatedFile, clazz, method)
      end
    end
    return DynamicString.new(relatedFile, exp.line, exp, values)
  end

  def self.processCall(exp, relatedFile, clazz, method)
    linkedFunction = LinkedFunctionProcess.new.initProcess(exp, relatedFile, clazz, method)
    return linkedFunction
  end

  def self.getNamesFromConst(exp)
    if(exp.class == Sexp && !exp[2].nil?)
      vet = self.getNamesFromConst(exp[1])
      vet << exp[2]
      return vet
    elsif(exp.class == Sexp && exp[2].nil?)
      return self.getNamesFromConst(exp[1])
    else
      return [exp]
    end
  end


  def self.getImplicitReturnFromIf(exp)
    _, condExp, blockExp, elseExp = exp
    implicitReturns = []
    implicitReturns.concat(self.getImplicitReturn(blockExp)) if !blockExp.nil?
    implicitReturns.concat(self.getImplicitReturn(elseExp)) if !elseExp.nil?
    return implicitReturns
  end

  def self.getImplicitReturnFromCase(exp)
    _, condExp, *whensExp, defaultCaseExp = exp
    implicitReturns = []
    whensExp.each do |whenExp|
      implicitReturns.concat(self.getImplicitReturn(whenExp[2]))
    end
    implicitReturns.concat(self.getImplicitReturn(defaultCaseExp)) if !defaultCaseExp.nil?
    return implicitReturns
  end

  def self.getImplicitReturn(exp)
    if(exp[0] == :if)
      return self.getImplicitReturnFromIf(exp)
    elsif(exp[0] == :case)
      return self.getImplicitReturnFromCase(exp)
    elsif(exp[0] == :block)
      return self.getImplicitReturn(exp.last)
    else
      return [exp]
    end
  end
end