require_relative "../collectedDatas/staticValues/self_instance"
module SendModule

  def isPrivateMethod(baseInfers, methodName)
    return false if methodName == :include
    methodName = "#{methodName}".to_sym
    visibility = nil
    baseInfers.each do |infer|
      if(infer.isSelfInstance?)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.value)
        method = clazz.getStaticMethodByName(methodName) if !clazz.nil?
      else
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.type)
        method = clazz.getInstanceMethodByName(methodName) if !clazz.nil?
      end
      if(!method.nil?)
        visibility = method.visibility
      elsif(method.nil?)
        return nil
      end
    end
    if(!visibility.nil?)
      return visibility == :protected || visibility == :private
    else
      return nil
    end
  end

  def createSendMark(privateMethod)
    mark = ""
    if(!privateMethod.nil? && privateMethod)
      mark = "#modifique a visibilidade do metodo"
    elsif(privateMethod.nil?)
      mark = "#nao foi possivel verificar a visibilidade do metodo"
    end
    return mark
  end

  #send(:foo) or Clazz.send(:foo) or obj.send(:foo)
  def tryFirstSuggestionToSend(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.class == LiteralDef)
      rootInfers = root.nil? ? Set.new : root.infers
      privateMethod = isPrivateMethod(rootInfers, firstParameter.value)
      safeRecommendation = !privateMethod.nil?
      msg = "Invoque a funçao #{firstParameter.value} diretamente: #{firstParameter.value}(#{function.parameters_to_s(1)}) #{createSendMark(privateMethod)}"
      return true, safeRecommendation, msg, 0
    end
    return nil, nil, nil, nil
  end

  #send(var) or Clazz.send(var) or obj.send(var)
  def trySecondSuggestionToSend(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(firstParameter.infers.size > 0)
      rootInfers = root.nil? ? Set.new : root.infers
      infers = firstParameter.infers.to_a
      privateMethod = isPrivateMethod(rootInfers, infers[0].value)
      safeRecommendation = !privateMethod.nil?
      ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{linkedFunction.to_s(function)}.#{infers[0].value}(#{function.parameters_to_s(1)}) #{createSendMark(privateMethod)}"
      for i in 1..infers.size-1
        privateMethod = isPrivateMethod(rootInfers, infers[i].value)
        safeRecommendation = safeRecommendation && !privateMethod.nil?
        ifSuggestion = "#{ifSuggestion}\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{linkedFunction.to_s(function)}.#{infers[i].value}(#{function.parameters_to_s(1)}) #{createSendMark(privateMethod)}"
      end
      ifSuggestion = "#{ifSuggestion}\nelse\n  #{function.to_s}\nend"
      return true, safeRecommendation, ifSuggestion, 3 + 2 * firstParameter.infers.size
    else
      return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}", 0
    end
  end

  def recommendSend(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(!firstParameter.nil?)
      [:tryFirstSuggestionToSend,
       :trySecondSuggestionToSend].each do |methodToMakeSuggestion|
        success, safeRecommendation, msg, loc = send(methodToMakeSuggestion, linkedFunction, root, function)
        return success, safeRecommendation,msg, loc if !success.nil?
      end
    end
    return false, false, "Sem sugestao", 0
  end
end
