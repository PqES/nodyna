require_relative "../collectedDatas/discovered_classes"
module ConstGetModule

  def isPrivateConstant(baseInfers, constName)
    privateConstant = nil
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

  #Test.const_get(:CONST) or obj.class.const_get(:CONST)
  def tryFirstSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.class == LiteralDef)
      privateConstant = isPrivateConstant(root.infers, firstParameter.value)
      msg = "Obtenha a constante diretamente: #{root.to_s}::#{firstParameter.value} #{printConstGetMark(privateConstant)}"
      return true, !privateConstant.nil?, msg
    end
    return nil, nil, nil
  end

  #Test.const_get(var) or obj.class.const_get(var)
  def trySecondSuggestionToConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.isDynamicValue?)
      infers = firstParameter.infers.to_a
      if(infers.size > 0)
        privateConstant = isPrivateConstant = isPrivateConstant(root.infers, infers[0].value)
        ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value}) \n  #{root.to_s}::#{infers[0].value} #{printConstGetMark(privateConstant)}"
        safeRecommendation = !privateConstant.nil?
        for i in 1..infers.size-1
          privateConstant = isPrivateConstant = isPrivateConstant(root.infers, infers[i].value)
          safeRecommendation = safeRecommendation && !privateConstant.nil?
          ifSuggestion = " #{ifSuggestion}\nelsif(#{firstParameter.to_s} == #{infers[i].value}) \n  #{root.to_s}::#{infers[i].value} #{printMark(privateConstant)}"
        end
        ifSuggestion = "#{ifSuggestion}\nelse\n  #{function.to_s}"
        return true, safeRecommendation, ifSuggestion
      else
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}"
      end
    end
    return nil, nil, nil
  end

  def recommendConstGet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!root.nil? && !firstParameter.nil?)
      if(root.infers.size == 0)
        return false, false, "Nao foi possivel inferir as classes que invocam const_get"
      end
      [:tryFirstSuggestionToConstGet,
       :trySecondSuggestionToConstGet].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg if !success.nil?
      end
    end
    return false, false, "Sem sugestao"
  end
end