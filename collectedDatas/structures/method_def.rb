require_relative "../../collectedDatas/infers/inferable"
class MethodDef < BasicData
  include Inferable

  attr_reader :name, :variables, :instanceMethod, :statements
  attr_accessor :visibility

  def initialize(rbfile, line, exp, name, instanceMethod)
    super(rbfile, line, exp)
    initInferableModule()
    @instanceMethod = instanceMethod
    @visibility = visibility
    @name = name
    @variables = {}
    @formalParameters = []
    @statements = Set.new
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def addFormalParameter(variable)
    @formalParameters << variable
    addVariable(variable)
  end

  def getFormalParameter(index)
    if(index >= 0 && index < @formalParameters.size )
      return @formalParameters[index]
    end
    return nil
  end

  def addVariable(variable)
    @variables[variable.name] = variable
  end

  def getVariableByName(varName)
    if(@variables.has_key?(varName))
      return @variables[varName]
    end
    return nil
  end

  def addStatement(statement)
    @statements << statement
  end

  def infer()
    @statements.each do |statement|
      statement.infer()
    end
  end

  def printCollectedData(spaces = 0)
    str = "#{@visibility} #{@name}("
    if(@formalParameters.size > 0)
      @formalParameters.each do |parameter|
        str = "#{str}#{parameter.printCollectedData()},"
      end
      str.chop!
    end
    str = "#{str}) #{printInferData}"
    @variables.each do |varName, variable|
      str = "#{str}\n#{" " * spaces}    var #{variable.printCollectedData()}"
    end
    @statements.each do |statement|
      str = "#{str}\n#{" " * spaces}    statement #{statement.printCollectedData()}"
    end
    return str
  end
end