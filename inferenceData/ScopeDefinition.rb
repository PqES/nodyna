module ScopeDefinition
  attr_reader :variables

  def initScopeModule
    @variables = {}
  end
 
  def addVariable(var)
    @variables[var.name] = var
  end
 
  def getVariable(varName)
    if(@variables.has_key?(varName.to_s))
      return @variables[varName.to_s] 
    else
      return nil
    end
  end

end
