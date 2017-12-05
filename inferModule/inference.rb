require_relative "../collectedDatas/discovered_classes"

class Inference

  def self.infer()
    DiscoveredClasses.instance.classes.each do |className, clazz|
      clazz.instanceMethods.each do |methodName, method|
        self.callInfers(method.statements)
      end
      clazz.staticMethods.each do |methodName, method|
        self.callInfers(method.statements)
      end
      self.callInfers(clazz.statements)
    end
  end

  def self.callInfers(statements)
    statements.each do |statement|
      statement.infer()
    end
  end
end