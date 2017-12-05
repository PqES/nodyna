require_relative "../collectedDatas/self_instance"
module SendModule

  def isPrivateMethod(baseInfers, methodName)
    methodName = "#{methodName}".to_sym
    visibility = :public
    baseInfers.each do |infer|
      if(infer.obj.class != SelfInstance)
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.type)
        method = clazz.getInstanceMethodByName(methodName) if !clazz.nil?
      else
        clazz = DiscoveredClasses.instance.getClassByFullName(infer.value)
        method = clazz.getStaticMethodByName(methodName) if !clazz.nil?
      end
      if(!method.nil? && (method.visibility == :protected || method.visibility == :private))
        visibility = method.visibility
      elsif(method.nil?)
        return nil
      end
    end
    return visibility == :protected || visibility == :private
  end

  def createSuggestion(function, baseInfers, methodName)
    suggestion = "#{methodName}(#{function.parameters_to_s(1)})"
    isPrivate = self.isPrivateMethod(baseInfers, methodName)
    if(isPrivate)
      suggestion = "#{suggestion} #modifique a visibilidade do metodo"
    elsif(isPrivate.nil?)
      suggestion = "#{suggestion} #nao foi possivel verificar a visibilidade do metodo"
    end
    return suggestion
  end

  def recommendSend(root, function)
    baseInfers = root.infers.to_a
    firstParameter = function.getParameter(0)
    if(!firstParameter.nil? && firstParameter.class == LiteralDef)
      msg = createSuggestion(function, baseInfers, firstParameter.value)
      return true, msg
    elsif(!firstParameter.nil?)
      infers = firstParameter.infers.to_a
      if(infers.size > 0)
        ifSuggestion = "if(#{firstParameter.to_s} == #{infers[0].value})\n  #{createSuggestion(function, baseInfers, infers[0].value)}"
        for i in 1..infers.size-1
          ifSuggestion = "#{ifSuggestion}\nelsif(#{firstParameter.to_s} == #{infers[i].value})\n  #{createSuggestion(function, baseInfers, infers[i].value)}"
        end
        ifSuggestion = "#{ifSuggestion}\nelse\n  #{function.to_s}"
        return true, ifSuggestion
      else
        return false, "Nao foi possivel verificar os valores de #{firstParameter.to_s}"
      end
    end
    return false, "Sem recomendaçao"
    puts "#{"="*80}"
  end
end