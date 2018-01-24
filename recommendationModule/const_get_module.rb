require_relative "../collectedDatas/discovered_classes"
module ConstGetModule

  def isPrivateConstant?(baseInfers, constName)
    privateConstant = nil
    constName = constName.to_sym if !constName.nil?
    baseInfers.each do |infer|
      if(infer.isSelfInstance?)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.value)
        if(!clazz.nil?)
          constant = clazz.getConstantByName(constName)
          if(!constant.nil?)
            privateConstant = constant.isPrivate?
          else
            return nil
          end
        else
          return nil
        end
      end
    end
    return privateConstant
  end

  def printConstGetMark(privateConstant)
    mark = ""
    if(!privateConstant.nil? && privateConstant)
      mark = "#modifique a visibilidade da constante"
    elsif(privateConstant.nil?)
      mark = "#nao foi possivel verificar a visibilidade da constante"
    end
    return mark
  end

  #const_get(:FOO)
  def tryFirstSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.class == SelfInstance && firstParameter.class == LiteralDef)
      msg = "#{firstParameter.value}"
      return true, true, msg
    end
    return nil, nil, nil
  end

  #const_get(x)
  def trySecondSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.class == SelfInstance && firstParameter.isDynamicValue?)
      infers = firstParameter.infers.to_a
      ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{infers[0].value}"
      for i in 1 .. infers.size - 1
        ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{infers[i].value}"
      end
      ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
      return true, true, ifSuggestion
    end
    return nil, nil, nil
  end

  #obj.const_get(:FOO)
  def tryThirdSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.isDynamicValue? && firstParameter.class == LiteralDef)
      privateConstant = isPrivateConstant?(root.infers, firstParameter.value)
      safe = !privateConstant.nil?
      suggestion = "#{linkedFunction.to_s(function)}::#{firstParameter.value} #{printConstGetMark(privateConstant)}"
      return true, safe, suggestion
    end
    return nil, nil, nil
  end

  #Test.const_get(var) or obj.class.const_get(var)
  def tryForthSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.isDynamicValue? && firstParameter.isDynamicValue?)
      infers = firstParameter.infers.to_a
      privateConstant = isPrivateConstant?(root.infers, infers[0].value)
      safe = !privateConstant.nil?
      ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}::#{infers[0].value} #{printConstGetMark(privateConstant)}"
      for i in 1 .. infers.size - 1
        privateConstant = isPrivateConstant?(root.infers, infers[i].value)
        safe = !privateConstant.nil?
        ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}::#{infers[i].value} #{printConstGetMark(privateConstant)}"
      end
      ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
      return true, safe, ifSuggestion
    end
    return nil, nil, nil
  end

  def recommendConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!root.nil? && !firstParameter.nil?)
      if(firstParameter.infers.size == 0)
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter}"
      end
      [:tryFirstSuggestionToConstGet,
       :trySecondSuggestionToConstGet,
      :tryThirdSuggestionToConstGet,
       :tryForthSuggestionToConstGet].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg if !success.nil?
      end
    end
    return false, false, "Sem sugestao"
  end
end