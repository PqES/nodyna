class Recommendation  
  
  class << self
    
    def makeRecommendations(allClasses)
      allClasses.each do |className, clazz|
        clazz.methods.each do |methodName, method|
          method.statements.each do |statement|
            statement.recommend(allClasses, className, methodName)
          end
          method.returns.each do |statement|
            statement.recommend(allClasses, className, methodName)
          end
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
    
    def recommendSend(allClasses, className, methodName, typeInferences, func)
      if(func.params.size > 0)
        if(func.params[0].class == ValueDefinition)
          if(isPrivateMethod(allClasses, func.params[0].value))
            puts "[SEND] Troque o send para invocação normal e também troque sua visibilidade para público"
          else
            puts "[SEND] Troque o send para invocação normal"
          end
        else
          _, values, _ = func.params[0].infer(allClasses, className, methodName)
          if(values.size > 0 && isPrivateMethod(allClasses, methodName))
            puts "[SEND] Faça um switch case com os valores #{values.to_a.to_s} (como última opção deixe o send) e também troque sua visibilidade para público"
          elsif(values.size > 0)
            puts "[SEND] Faça um switch case com os valores #{values.to_a.to_s} (como última opção deixe o send)"
          end
        end
      end
    end
    
    def recommendConstGet(allClasses, className, methodName, typeInferences, func)
      if(func.params.size > 0)
        if(func.params[0].class == ValueDefinition)
          puts "[CONST_GET] Obtenha a constante em forma natural"
        else
          _, values, _ = func.params[0].infer(allClasses, className, methodName)
          if(values.size > 0)
            puts "[CONST_GET] Faça um switch case com os valores #{values.to_a.to_s} (como última opção deixe o const_get)"
          end
        end
      end
    end
    
    def recommendConstSet(allClasses, className, methodName, typeInferences, func)
      if(func.params.size > 1)
        if(func.params[0].class == ValueDefinition && func.params[1].class == ValueDefinition)
          puts "[CONST_SET] Crie a constante nas classes: #{typeInferences.to_a.to_s} (faça um if da class com esses valores)"
        elsif(func.params[1].class == ValueDefinition)
          _, values, _ = func.params[0].infer(allClasses, className, methodName)
          if(values.size > 0)
            puts "[CONST_SET] Faça um switch case com os valores #{values.to_a.to_s} (como última opção deixe o const_get)"
          end
        end
      end
    end
  end
end