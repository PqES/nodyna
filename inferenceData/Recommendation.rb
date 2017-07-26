class Recommendation  
  
  class << self
    
    def makeRecommendations(allClasses)
      allClasses.each do |className, clazz|
        statementsRecomendation(clazz.statements, allClasses)
        clazz.methods.each do |methodName, method|
          statementsRecomendation(method.statements, allClasses)
          statementsRecomendation(method.returns, allClasses)
        end
        clazz.staticMethods.each do |methodName, method|
          statementsRecomendation(method.statements, allClasses)
          statementsRecomendation(method.returns, allClasses)
        end
      end
    end
    
    def statementsRecomendation(statements, allClasses)
      statements.each do |statement|
        if(!statement.nil?)
          statement.recommend(allClasses)
        end
      end    
    end


    def isPrivateMethod(allClasses, methodName)
      methodName = methodName.to_s
      allClasses.each do |className, clazz|
        clazz.methods do |methodName, method|
          if(method.isPrivate)
            return true
          end
        end
      end
      return false
    end
    
    def recommendSend(allClasses, func)
      if(func.params.size > 0)
        if(func.params[0].class == LiteralDefinition)
          if(isPrivateMethod(allClasses, func.functionName))
            puts "[\nSEND - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
            puts "     Troque o send para invocação normal e também troque sua visibilidade para público"
          else
            puts "\n[SEND - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
            puts "     Troque o send para invocação normal"
          end
        else
          firstParameter = func.params[0]
          if(!firstParameter.nil? && firstParameter.inference.values.size > 0 && isPrivateMethod(allClasses, func.functionName))
            puts "\n[SEND - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
            puts "     Faça um switch case com os valores #{firstParameter.values_str} (como última opção deixe o send) e também troque sua visibilidade para público"
          elsif(!firstParameter.nil? && firstParameter.inference.values.size > 0)
            puts "\n[SEND - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
            puts "     Faça um switch case com os valores #{firstParameter.values_str} (como última opção deixe o send)"
          end
        end
      end
    end
    
    def values_str(inferenceValues)
      str = "["
      inferenceValues.each do |v|
      str += v.to_s + " "
      end
      str += "]"
    end

    def recommendConstGet(allClasses, func, inference)
      if(func.params.size > 0 && inference.types.size > 0)
        if(func.params[0].class == LiteralDefinition)
          puts "\n[CONST_GET - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
          puts "     Obtenha a constante em forma natural das classes #{values_str(inference.values)}"
        elsif(func.params[0].inference.values.size > 0)
          puts "\n[CONST_GET - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
          puts "     Faça um switch case com os valores #{func.params[0].values_str} e nas classes #{values_str(inference.values)} (como última opção deixe o const_get)"
        end
      else
        #puts "[CONST_GET - #{func} (#{func.relatedFile}.#{func.relatedExp.line})] CONST_GET NOT REFACT"
      end
    end
    
    def recommendConstSet(allClasses, func, inference)
      if(func.params.size > 1 && inference.values.size > 0)
        if(func.params[0].class == LiteralDefinition && func.params[1].class == LiteralDefinition)
          puts "\n[CONST_SET - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
          puts "     Crie a constante nas classes: #{inference.values_str} (faça um if da class com esses valores)"
        elsif(func.params[0].inference.values.size > 0)
          puts "\n[CONST_SET - #{func} (#{func.relatedFile}.#{func.relatedExp.line})]"
          puts "     Faça um switch case com os valores #{inference.values_str} (como última opção deixe o const_set)"
        end
      end
    end
  end
end
