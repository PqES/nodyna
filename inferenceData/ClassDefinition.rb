class ClassDefinition < BasicDefinition
  include ScopeDefinition
  attr_reader :name, :methods, :staticMethods, :instanceVariables, :staticVariables, :statements

  def initialize(relatedFile,relatedExp, name)
    super(relatedFile,relatedExp)
    initScopeModule()
    @name = name.to_s
    @methods = {}
    @staticMethods = {}
    @instanceVariables = {}
    @staticVariables = {}
    @statements = []
  end
  
  def addInstanceMethod(method)
    @methods[method.name] = method
  end
  
  def addStaticMethod(method)
    @staticMethods[method.name] = method
  end

  def addStatement(statement)
    @statements << statement
  end
end
