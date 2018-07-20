require_relative "../collectedDatas/discovered_classes"
require_relative "../collectedDatas/staticValues/object_instance"
module ClassVariableSetModule

  def hasStaticSetter?(baseInfers, varName)
    hasSetter = nil
    baseInfers.each do |infer|
      if(infer.isSelfInstance?)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.value)
        if(!clazz.nil?)
          variable = clazz.getStaticVariableByName(varName)
          if(!variable.nil?)
            setterMethodName = "#{variable.name.to_s.sub("@@","")}=".to_sym
            hasSetter = !clazz.getStaticMethodByName(setterMethodName).nil?
          else
            return nil
          end
        else
          return nil
        end
      end
    end
    return hasSetter
  end

  def printMarkToCVS(hasSetter)
    if(!hasSetter.nil? && !hasSetter)
      return "#crie um set para a variavel"
    elsif(hasSetter.nil?)
      return "#nao foi possivel verificar a visibilidade da variavel"
    end
    return ""
  end


  #class_variable_set(:@@a, ...)
  def tryFirstSuggestionToCVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.class == LiteralDef && (root.class == SelfInstance))
      return true, true, "Faca a atribuiçao diretamente: #{firstParameter.value} = ...",0
    end
    return nil,nil,nil,nil
  end


  #class_variable_set(var)
  def trySecondSuggestionToCVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.isDynamicValue? && root.class == SelfInstance)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasSetter = hasStaticSetter?(root.infers, infers[0].value)
        safeRecommendation = !hasSetter.nil?
        ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{infers[0].value} = ... #{printMarkToCVS(hasSetter)}"
        for i in 1..infers.size - 1
          hasSetter = hasStaticSetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasSetter.nil?
          ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{infers[i].value} = ... #{printMarkToCVS(hasSetter)}"
        end
        ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifSuggestion,3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}",0
      end
    end
    return nil,nil,nil,nil
  end

  #obj.class_variable_set(:@a, ...)
  def tryThirdSuggestionToCVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.class == LiteralDef  && root.class != ObjectInstance)
      hasSetter = hasStaticSetter?(root.infers, firstParameter.value)
      safeRecommendation = !hasSetter.nil?
      ifSuggestion = "#{linkedFunction.to_s(function)}.#{firstParameter.value.to_s.sub("@@","")} = ... #{printMarkToCVS(hasSetter)}"
      return true, safeRecommendation, ifSuggestion, 0
    end
    return nil,nil,nil,nil
  end

  #obj.class_variable_set(var, ...)
  def tryForthSuggestionToCVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.isDynamicValue? && root.class != ObjectInstance)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasSetter = hasStaticSetter?(root.infers, infers[0].value)
        safeRecommendation = !hasSetter.nil?
        ifValues = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}.#{infers[0].value.to_s.sub("@@","")} = ... #{printMarkToCVS(hasSetter)}"
        for i in 1..infers.size - 1
          hasSetter = hasStaticSetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasSetter.nil?
          ifValues += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}.#{infers[i].value.to_s.sub("@@","")} = ... #{printMarkToCVS(hasSetter)}"
        end
        ifValues += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifValues,3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}",0
      end
    end
    return nil, nil, nil,nil
  end

  def recommendCVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!root.nil? && !firstParameter.nil?)
      [:tryFirstSuggestionToCVS,
       :trySecondSuggestionToCVS,
       :tryThirdSuggestionToCVS,
       :tryForthSuggestionToCVS].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg, loc = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg,loc if !success.nil?
      end
    end
    return false, false, "Sem sugestao",0
  end
end
