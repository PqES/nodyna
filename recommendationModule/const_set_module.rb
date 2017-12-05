module ConstSetModule
  def recommendConstSet(linkedFunction, root, function)
    msg = ""
    if(root.infers.size > 0)
      firstParameter = function.getParameter(0)
      secondParameter = function.getParameter(1)
      if(firstParameter.class == LiteralDef && secondParameter.class == LiteralDef)
        if(root.class == SelfInstance)
          msg = "Crie a constante #{firstParameter.value} com valor #{secondParameter.value} na classe #{root.value} diretamente"
          return true, msg
        else
          infers = root.infers.to_a
          strClasses = ""
          infers.each do |infer|
            strClasses = "#{strClasses}#{infer.value},"
          end
          strClasses.chop!
          strIfCase = "if !([#{strClasses}].include?(#{linkedFunction.to_s(function)})) #{linkedFunction.to_s}"
          msg = "Crie a constante #{firstParameter.value} com valor #{secondParameter.value} na(s) classe(s) #{strClasses} diretamente. Adicione tambem o if: \n #{strIfCase}"
          return true, msg
        end
      end
    else
      msg = "Nao foi possivel identificar as classes que invocam const_set"
      return false, msg
    end
    return false, "Sem recomendaçao"
    puts "#{"="*80}"
  end
end