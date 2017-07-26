class MethodDefinition < BasicDefinition
  include InferData
  include ScopeDefinition
  
  attr_reader :name, :returns, :statements
  def initialize(relatedFile,relatedExp, name, params)
    super(relatedFile,relatedExp)
    initScopeModule()
    initInferModule()
    @name = name.to_s
    @params = params
    @statements = []
    @returns = []
    extractVaribablesFromParams()
  end
  
  def isPrivate()
    return false
  end

  def extractVaribablesFromParams()
    @params.each do |var|
      addVariable(var)
    end
  end
    
  def addStatement(statement)
    if(statement.class == AssignmentDefinition && !@variables.has_key?(statement.var.name))
      addVariable(statement.var)
    end
    @statements << statement
  end
  
  def addReturn(value)
    @returns << value
  end
   
  def mergeParams(params, allClasses, className, methodName)
    newInfers = false
    for i in 0..params.count - 1
      if(!@params[i].nil? && !params[i].nil?)
        newInfers = params[i].infer(allClasses, className, methodName) || newInfers
        @params[i].addInfers(params[i].inference)
      end
    end
    return newInfers
  end
  
  def infer(allClasses, className, methodName)
    newInfers = false
    @returns.each do |returnStatement|
      if(!returnStatement.nil?)
        newInfers = returnStatement.infer(allClasses, className, methodName) || newInfers
        addInfers(returnStatement.inference)
      end
    end
    return newInfers
  end
end
