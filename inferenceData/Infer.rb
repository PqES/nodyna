class Infer  
  class << self
    
    def infer(classes)
      newInfers = true
      while(newInfers)
        newInfers = false
        classes.each do |className, clazz|
          newInfers = statementsInfer(classes,className, nil, clazz.statements) || newInfers
          clazz.methods.each do |methodName, method|
            newInfers = statementsInfer(classes, className, methodName, method.statements) || newInfers
            newInfers = statementsInfer(classes, className, methodName, method.returns) || newInfers
          end
        end
      end
    end
    
    def statementsInfer(classes, className, methodName, statements)
      newInfers = false
      statements.each do |statement|
        if(!statement.nil?)
          newInfers = statement.infer(classes, className, methodName) || newInfers
        end
      end
      return newInfers
    end
    
  end
end
