require_relative "send_module"
require_relative "const_set_module"
class Recommendation
  extend SendModule
  extend ConstSetModule

  def self.recommend()
    DiscoveredClasses.instance.classes.each do |className, clazz|
      clazz.instanceMethods.each do |methodName, method|
        method.statements.each do |statement|
          self.recommendLinkedFunction(statement) if statement.class == LinkedFunctions
        end
      end
      clazz.staticMethods.each do |methodName, method|
        method.statements.each do |statement|
          self.recommendLinkedFunction(statement) if statement.class == LinkedFunctions
        end
      end
      clazz.statements.each do |statement|
        self.recommendLinkedFunction(statement) if statement.class == LinkedFunctions
      end
    end
  end

  def self.recommendLinkedFunction(statement)
    root = statement.root
    statement.functions.each do |func|
      self.recommendFunction(statement, root, func)
      root = func
    end
  end

  def self.recommendFunction(linkedFunction, root, function)
    success, msg = nil, nil
    if(function.methodName == :send)
      puts "send identificado no arquivo #{function.rbfile} linha #{function.line}"
      success, msg = self.recommendSend(root, function)
    elsif(function.methodName == :instance_variable_get)
    elsif(function.methodName == :instance_variable_set)
    elsif(function.methodName == :class_variable_get)
    elsif(function.methodName == :class_variable_set)
    elsif(function.methodName == :const_set)
      puts "const_set identificado no arquivo #{function.rbfile} linha #{function.line}"
      success, msg = self.recommendConstSet(linkedFunction, root, function)
    elsif(function.methodName == :const_get)
    end
    if(!success.nil? && !msg.nil?)
      if(success)
        puts "Sugestao:\n#{msg}"
      else
        puts msg
      end
      puts "#{"=" * 80}"
    end
  end
end