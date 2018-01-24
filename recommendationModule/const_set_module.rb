require_relative "../collectedDatas/const_call"
require_relative "../collectedDatas/staticValues/self_instance"
require_relative "../collectedDatas/staticValues/literal_def"
module ConstSetModule



  #const_set(:CONST, :X)
  def tryFirstSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.class == SelfInstance && firstParameter.class == LiteralDef)
      msg = "#{firstParameter.value} = ..."
      return true, true, msg
    end
    return nil, nil, nil
  end

  #const_set(x, :X)
  def trySecondSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.class == SelfInstance && firstParameter.isDynamicValue?)
      infers = firstParameter.infers.to_a
      ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{infers[0].value} = ..."
      for i in 1 .. infers.size - 1
        ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{infers[i].value} = ..."
      end
      ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
      return true, true, ifSuggestion
    end
    return nil, nil, nil
  end

  #obj.const_set(:CONST, :X)
  def tryThirdSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.isDynamicValue? && firstParameter.class == LiteralDef)
      privateConstant = isPrivateConstant?(root.infers, firstParameter.value)
      safe = !privateConstant.nil?
      suggestion = "#{linkedFunction.to_s(function)}::#{firstParameter.value} = ... #{printConstGetMark(privateConstant)}"
      return true, safe, suggestion
    end
    return nil, nil, nil
  end

  #obj.class.const_set(x)
  def tryForthSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.isDynamicValue? && firstParameter.isDynamicValue?)
      infers = firstParameter.infers.to_a
      privateConstant = isPrivateConstant?(root.infers, infers[0].value)
      safe = !privateConstant.nil?
      ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}::#{infers[0].value} = ... #{printConstGetMark(privateConstant)}"
      for i in 1 .. infers.size - 1
        privateConstant = isPrivateConstant?(root.infers, infers[i].value)
        safe = !privateConstant.nil?
        ifSuggestion += "\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}::#{infers[i].value} = ... #{printConstGetMark(privateConstant)}"
      end
      ifSuggestion += "\nelse\n  #{linkedFunction.to_s}\nend"
      return true, safe, ifSuggestion
    end
    return nil, nil, nil
  end

  def recommendConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!firstParameter.nil? && !root.nil?)
      if(firstParameter.infers.size == 0)
        return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}"
      end
      [:tryFirstSuggestionToConstSet,
       :trySecondSuggestionToConstSet,
       :tryThirdSuggestionToConstSet,
       :tryForthSuggestionToConstSet].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg if !success.nil?
      end
    end
    return false, false, "Sem sugestao"
  end
end