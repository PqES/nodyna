require_relative "../collectedDatas/discovered_classes"
require_relative "../collectedDatas/staticValues/object_instance"
module InstanceVariableSetModule

  def hasSetter?(baseInfers, varName)
    hasSetter = nil
    baseInfers.each do |infer|
      if(!infer.isSelfInstance?)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.type)
        if(!clazz.nil?)
          variable = clazz.getInstanceVariableByName(varName)
          if(!variable.nil?)
            hasSetter = variable.hasSetter?
            if(!hasSetter)
              setterMethodName = "#{variable.name.to_s.sub("@","")}=".to_sym
              hasSetter = !clazz.getInstanceMethodByName(setterMethodName).nil?
            end
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

  def printMarkToIVS(hasSetter)
    if(!hasSetter.nil? && !hasSetter)
      return "#crie um set para a variavel"
    elsif(hasSetter.nil?)
      return "#nao foi possivel verificar a visibilidade da variavel"
    end
    return ""
  end


  #instance_variable_set(:@a, ...)
  def tryFirstSuggestionToIVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.class == LiteralDef && root.class == ObjectInstance)
      return true, true, "Realize a atribuiçao diretamente: #{firstParameter.value} = ...", 0
    end
    return nil,nil,nil,nil
  end


  #instance_variable_set(var, ...)
  def trySecondSuggestionToIVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.isDynamicValue? && root.class == ObjectInstance)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasSetter = hasSetter?(root.infers, infers[0].value)
        safeRecommendation = !hasSetter.nil?
        ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{infers[0].value} = ... #{printMarkToIVS(hasSetter)}"
        for i in 1..infers.size - 1
          hasSetter = hasSetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasSetter.nil?
          ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{infers[i].value} ... #{printMarkToIVS(hasSetter)}"
        end
        ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifSuggestion,3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}",0
      end
    end
    return nil,nil,nil,nil
  end

  #obj.instance_variable_Set(:@a, ...)
  def tryThirdSuggestionToIVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.class == LiteralDef && root.isDynamicValue?)
      hasSetter = hasSetter?(root.infers, firstParameter.value)
      safeRecommendation = !hasSetter.nil?
      msg = "#{linkedFunction.to_s(function)}.#{firstParameter.value.to_s.sub("@","")} = ... #{printMarkToIVS(hasSetter)}"
      return true, safeRecommendation, msg, 0
    end
    return nil, nil, nil, nil
  end

  #obj.instance_variable_set(var)
  def tryForthSuggestionToIVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(firstParameter.isDynamicValue? && root.isDynamicValue?)
      if(firstParameter.infers.size > 0)
        infers = firstParameter.infers.to_a
        hasSetter = hasSetter?(root.infers, infers[0].value)
        safeRecommendation = !hasSetter.nil?
        ifValues = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}.#{infers[0].value.to_s.sub("@","")} = ... #{printMarkToIVS(hasSetter)}"
        for i in 1..infers.size - 1
          hasSetter = hasSetter?(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !hasSetter.nil?
          ifValues += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}.#{infers[i].value.to_s.sub("@","")} = ... #{printMarkToIVS(hasSetter)}"
        end
        ifValues += "\nelse\n  #{linkedFunction.to_s}\nend"
        return true, safeRecommendation, ifValues, 3 + 2 * firstParameter.infers.size
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}", 0
      end
    end
    return nil, nil, nil, nil
  end

  def recommendIVS(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!root.nil? && !firstParameter.nil?)
      [:tryFirstSuggestionToIVS,
       :trySecondSuggestionToIVS,
       :tryThirdSuggestionToIVS,
       :tryForthSuggestionToIVS].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg, loc = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg, loc if !success.nil?
      end
    end
    return false, false, "Sem sugestao", 0
  end
end
