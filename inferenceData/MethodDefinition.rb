class MethodDefinition
  include InferData
  
  attr_reader :name, :returns, :statements, :typeInferences, :valueInferences, :variables
  def initialize(name, params)
    @name = name.to_s
    @params = params
    @variables = {}
    @statements = []
    @returns = []
    @typeInferences = Set.new
    @valueInferences = Set.new
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
  
  def getVariable(varName)
    if(@variables.has_key?(varName.to_s))
      return @variables[varName.to_s] 
    else
      return nil
    end
  end
  
  def addVariable(var)
    @variables[var.name] = var
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
  
  
  def addInfers(types, values)
    newTypes = addTypeInferences(types)
    newValues= addValueInferences(values)
    return newTypes || newValues  
  end
  
  def addTypeInferences(infers)
    oldSize = @typeInferences.size
    @typeInferences.merge(infers)
    newSize = @typeInferences.size
    return newSize > oldSize #retorna se teve novas infererências.
  end
  
  def addValueInferences(infers)
    oldSize = @valueInferences.size
    @valueInferences.merge(infers)
    newSize = @valueInferences.size
    return newSize > oldSize #retorna se teve novas infererências.
  end
  
  def mergeParams(params, allClasses, className, methodName)
    newInfers = false
    for i in 0..params.count - 1
      types, values, tempNewInfers = params[i].infer(allClasses, className, methodName)
      newInfers = newInfers || tempNewInfers || @params[i].addInfers(types, values)
    end
    return newInfers
  end
  
end