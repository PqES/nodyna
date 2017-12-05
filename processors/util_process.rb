require_relative "../collectedDatas/ConstCall"
require_relative "../collectedDatas/linked_functions"
require_relative "../collectedDatas/literal_def"
require_relative "../collectedDatas/array_def"
class UtilProcess

  def self.getValue(exp, relatedFile, clazz, method)
    value = nil
    if(:lit == exp[0] || :str == exp[0])
      value = self.processLit(exp, relatedFile, clazz, method)
    elsif(:array == exp[0])
      value = self.processArray(exp, relatedFile, clazz, method)
    elsif(:lvar == exp[0])
      value = self.processLvar(exp, relatedFile, clazz, method)
    elsif(:ivar == exp[0])
      value = self.processIvar(exp, relatedFile, clazz, method)
    elsif(:const == exp[0] || :colon2 == exp[0])
      value = self.processConst(exp, relatedFile, clazz, method)
    elsif(:call == exp[0])
      value = self.processCall(exp, relatedFile, clazz, method)
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
      elementValue = UtilProcess.getValue(elementExp, relatedFile, clazz, method)
      elements << elementValue if(!elementValue.nil?)
    end
    return ArrayDef.new(relatedFile, exp, exp.line, elements)
  end

  def self.processLvar(exp, relatedFile, clazz, method)
    return method.nil? ? clazz.getLocalVariableByName(exp[1]) : method.getVariableByName(exp[1])
  end

  def self.processIvar(exp, relatedFile, clazz, method)
    return clazz.getInstanceVariableByName(exp[1])
  end

  def self.processConst(exp, relatedFile, clazz, method)
    names = self.getNamesFromConst(exp)
    return ConstCall.new(relatedFile, exp, exp.line, names, clazz)
  end

  def self.processCall(exp, relatedFile, clazz, method)
    return LinkedFunctionProcess.new.initProcess(exp, relatedFile, clazz, method)
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
end