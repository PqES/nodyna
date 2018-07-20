require_relative "../collectedDatas/discovered_classes"
require_relative "../collectedDatas/staticValues/object_instance"
module ClassVariableGetModule

  def hasStaticGetter?(baseInfers, varName)
    hasGetter = nil
    baseInfers.each do |infer|
      if(infer.isSelfInstance?)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.value)
        if(!clazz.nil?)
          variable = clazz.getStaticVariableByName(varName)
          if(!variable.nil?)
            hasGetter = variable.hasGetter?
            if(!hasGetter)
              getterMethodName = variable.name.to_s.sub("@@","").to_sym
              hasGetter = !clazz.getStaticMethodByName(getterMethodName).nil?
            end
          else
            return nil
          end
        else
          return nil
        end
      end
    end
    return hasGetter
  end

  def printMarkToCVG(hasGetter)
    if(!hasGetter.nil? && !hasGetter)
      return "#crie um get para a variavel"
    elsif(hasGetter.nil?)
      return "#nao foi possivel verificar a visibilidade da variavel"
    end
    return ""
  end


  #class_variable_get(:@@a)
  def tryFirstSuggestionToCVG(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.class == LiteralDef && root.class == SelfInstance)
      return true, true, "Chame a variavel diretamente: #{firstParameter.value}",0
    end
    return nil,nil,nil,nil
  end


  #class_variable_get(var)
  def trySecondSuggestionToCVG(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.isDynamicValue? && root.class == SelfInstance)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasGetter = hasStaticGetter?(root.infers, infers[0].value)
        safeRecommendation = !hasGetter.nil?
        ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{infers[0].value} #{printMarkToCVG(hasGetter)}"
        for i in 1..infers.size - 1
          hasGetter = hasStaticGetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasGetter.nil?
          ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{infers[i].value} #{printMarkToCVG(hasGetter)}"
        end
        ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifSuggestion,3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}",0
      end
    end
    return nil,nil,nil,nil
  end

  #obj.class_variable_get(:@a)
  def tryThirdSuggestionToCVG(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.class == LiteralDef  && root.class != ObjectInstance)
      hasGetter = hasStaticGetter?(root.infers, firstParameter.value)
      safeRecommendation = !hasGetter.nil?
      ifSuggestion = "#{linkedFunction.to_s(function)}.#{firstParameter.value.to_s.sub("@@","")}() #{printMarkToCVG(hasGetter)}"
      return true, safeRecommendation, ifSuggestion,0
    end
    return nil, nil,nil,nil
  end

  #obj.class_variable_get(var)
  def tryForthSuggestionToCVG(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.isDynamicValue?  && root.class != ObjectInstance)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasGetter = hasStaticGetter?(root.infers, infers[0].value)
        safeRecommendation = !hasGetter.nil?
        ifValues = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}.#{infers[0].value.to_s.sub("@@","")}() #{printMarkToCVG(hasGetter)}"
        for i in 1..infers.size - 1
          hasGetter = hasStaticGetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasGetter.nil?
          ifValues += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}.#{infers[i].value.to_s.sub("@@","")}() #{printMarkToCVG(hasGetter)}"
        end
        ifValues += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifValues, 3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}",0
      end
    end
    return nil, nil, nil,nil
  end

  def recommendCVG(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!root.nil? && !firstParameter.nil?)
      [:tryFirstSuggestionToCVG,
       :trySecondSuggestionToCVG,
       :tryThirdSuggestionToCVG,
       :tryForthSuggestionToCVG].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg,loc = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg,loc if !success.nil?
      end
    end
    return false, false, "Sem sugestao", 0
  end
end
