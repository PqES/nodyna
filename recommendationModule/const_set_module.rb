require_relative "../collectedDatas/const_call"
require_relative "../collectedDatas/staticValues/self_instance"
require_relative "../collectedDatas/staticValues/literal_def"
module ConstSetModule


  #Clazz.const_set(:CONST, :X)
  def tryFirstSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(root.class == SelfInstance || (root.class == ConstCall && root.isStatic?))
      if(firstParameter.class == LiteralDef && secondParameter.isStaticValue?)
        msg = "Crie a constante #{firstParameter.value} com valor #{secondParameter.to_s} na classe #{root.value} diretamente"
        return true, false, msg
      end
    end
    return nil, nil, nil
  end

  #Clazz.const_set(x, :X)
  def trySecondSuggestionToConstSet(linkedFunction, root, function)
    if((root.class == SelfInstance || (root.class == ConstCall && root.isStatic?)))
      firstParameter = function.getParameter(0)
      if(firstParameter.isDynamicValue?)
        if(firstParameter.infers.size > 0)
          secondParameter = function.getParameter(1)
          strValues = ""
          firstParameter.infers.each do |infer|
            strValues = "#{strValues}#{infer.value},"
          end
          strValues.chop!
          strIfCase = "if (![#{strValues}].include?(#{firstParameter.to_s})) #{linkedFunction.to_s}"
          msg = "Crie a(s) constante(s) #{strValues} na classe #{root.value} com valor #{secondParameter.to_s}. Adicione tambem a condiçao:\n#{strIfCase}"
          return true, false, msg
        else
          return false, false, "Nao foi possivel inferir os valores de #{firstParameter.to_s}"
        end
      end
    end
    return nil, nil, nil
  end

  #obj.class.const_set(:CONST, :X)
  def tryThirdSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    if(root.isDynamicValue? && firstParameter.isStaticValue?)
      secondParameter = function.getParameter(1)
      strClasses = ""
      root.infers.each do |infer|
        strClasses = "#{strClasses}#{infer.value},"
      end
      strIfCase = "if (![#{strClasses}].include?(#{linkedFunction.to_s(function)})) #{linkedFunction.to_s}"
      msg = "Crie a constante #{firstParameter.value} na(s) classe(s) #{strClasses} com valor #{secondParameter.to_s}. Adicione tambem a condiçao:\n#{strIfCase}"
      return true, false, msg
    end
    return nil, nil, nil
  end

  #obj.class.const_set(x)
  def tryForthSuggestionToConstSet(linkedFunction, root, function)
    firstParameter = function.getParameter(0)
    secondParameter = function.getParameter(1)
    if(root.isDynamicValue? && firstParameter.isDynamicValue?)
      if(firstParameter.infers.size > 0)
        strClasses = ""
        root.infers.each do |infer|
          strClasses = "#{strClasses}#{infer.value},"
        end
        strClasses.chop!
        strValues = ""
        firstParameter.infers.each do |infer|
          strValues = "#{strValues}#{infer.value},"
        end
        strValues.chop!
        strIfCase = "if (![#{strClasses}].include?(#{linkedFunction.to_s(function)}) || ![#{strValues}].include?(#{firstParameter.to_s})) #{linkedFunction.to_s}"
        msg = "Crie a(s) constante(s) #{strValues} na(s) classe(s) #{strClasses} com valor #{secondParameter.to_s}. Adicione tambem a condiçao:\n#{strIfCase}"
        return true, false, msg
      else
        return false, false, "Nao foi possivel inferir os valores da constante a ser criada"
      end
    end
    return nil, nil, nil
  end

  def recommendConstSet(linkedFunction, root, function)
    secondParameter = function.getParameter(1)
    if(!function.getParameter(0).nil? && !secondParameter.nil? && !root.nil?)
      if(root.infers.size == 0)
        return false, false, "Nao foi possivel inferir as classes que invocam const_set"
      end
      if(!secondParameter.isStaticValue?)
        return false, false, "Segundo parametro e dinamico"
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