class ClassDefinition
  
  attr_reader :name, :methods
  def initialize(name)
    @name = name.to_s
    @methods = {}
    @staticMethods = {}
    @instanceVariables = {}
    @staticVariables = {}
  end
  
  
  def addMethod(method)
    @methods[method.name] = method
  end
  
end