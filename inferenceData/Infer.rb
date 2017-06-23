class Infer  
  class << self
    
    def infer(classes)
      newInfers = true
      while(newInfers)
        output = "*" * 80
        newInfers = false
        classes.each do |className, clazz|
          clazz.methods.each do |methodName, method|
            output =  "#{output}\n==== #{className}::#{methodName} ====\n"
            output =  "#{output}[STATEMENTS]"
            tempNewInfers, tempOutput = statementsInfer(classes, className, methodName, method.statements)
            output = "#{output}#{tempOutput}\n"
            output =  "#{output}[RETURNS]"
            newInfers = newInfers || tempNewInfers
            tempNewInfers, tempOutput = statementsInfer(classes, className, methodName, method.returns)
            output = "#{output}#{tempOutput}\n"
            output =  "#{output}[VARIABLES]"
            newInfers = newInfers || tempNewInfers
            output = "#{output}#{printVariables(method.variables)}"
          end
        end
        if(!newInfers)
          puts output
        end
      end
    end
    
    def statementsInfer(classes, className, methodName, statements)
      output = ""
      newInfers = false
      statements.each do |statement|
        types,  values, tempNewInfers = statement.infer(classes, className, methodName)
        output =  "#{output}\n#{statement.to_s} #{types.to_a.to_s} #{values.to_a.to_s}"
        if(tempNewInfers)
          newInfers = true
        end
      end
      return newInfers, output
    end
    
    def printVariables(variables)
      output = ""
      variables.each do |varName, varDef|
        output = "#{output}\n#{varDef.to_s} #{varDef.inferenceTypes.to_a.to_s} #{varDef.inferenceValues.to_a.to_s}"
      end
      return output
    end
    
  end
end