require_relative "../basic_data"
class ClassDef < BasicData

  attr_reader :name, :fullName, :instanceMethods, :staticMethods, :instanceVariables, :staticVariables, :statements, :innerClasses

  def initialize(rbfile, line, exp, name, fullName)
    super(rbfile, line, exp)
    @name = name.to_sym()
    @fullName = fullName.to_sym()
    @constants = {}
    @statements = Set.new
    @instanceMethods = {}
    @staticMethods = {}
    @localVariables = {}
    @instanceVariables = {}
    @staticVariables = {}
    @innerClasses = {}
  end

  def addInnerClass(classDef)
    @innerClasses[classDef.name] = classDef
  end

  def getInnerClassByName(className)
    if(@innerClasses.has_key?(className))
      return @innerClasses[className]
    end
    return nil
  end

  def addStatement(statement)
    @statements <<  statement
  end

  def addInstanceMethod(method)
    @instanceMethods[method.name] = method
  end

  def getInstanceMethodByName(methodName)
    if(@instanceMethods.has_key?(methodName))
      return @instanceMethods[methodName]
    end
    return nil
  end

  def addStaticMethod(method)
    @staticMethods[method.name] = method
  end

  def getStaticMethodByName(methodName)
    if(@staticMethods.has_key?(methodName))
      return @staticMethods[methodName]
    end
    return nil
  end

  def addConstant(constant)
    @constants[constant.name] = constant
  end

  def getConstantByName(constName)
    constName = constName.to_sym
    if(@constants.has_key?(constName))
      return @constants[constName]
    end
    return nil
  end

  def addLocalVariable(variable)
    @localVariables[variable.name] = variable
  end

  def getLocalVariableByName(varName)
    if(@localVariables.has_key?(varName))
      return @instanceVariables[varName]
    end
    return nil
  end

  def getInstanceVariableByName(varName)
    if(@instanceVariables.has_key?(varName))
      return @instanceVariables[varName]
    end
    return nil
  end

  def addInstanceVariable(variable)
    @instanceVariables[variable.name] = variable
  end

  def addStaticVariable(variable)
    @staticVariables[variable.name] = variable
  end

  def getStaticVariableByName(varName)
    if(@staticVariables.has_key?(varName))
      return @staticVariables[varName]
    end
    return nil
  end

  def printCollectedData(spaces = 0)
    str = "#{" " * spaces}#{@fullName}"
    @constants.each do |constName, const|
      str = "#{str}\n  constant (private: #{const.isPrivate?}) #{const.printCollectedData()}"
    end
    @staticVariables.each do |varName, var|
      str = "#{str}\n  static variable (Getter: #{var.hasGetter?} Setter: #{var.hasSetter?}) #{var.printCollectedData()}"
    end
    @instanceVariables.each do |varName, var|
      str = "#{str}\n  instance variable (Getter: #{var.hasGetter?} Setter: #{var.hasSetter?}) #{var.printCollectedData()}"
    end
    @instanceMethods.each do |methodName, method|
      str = "#{str}\n#{method.printCollectedData(2)}"
    end
    @staticMethods.each do |methodName, method|
      str = "#{str}\n#{method.printCollectedData(2)}"
    end
    @statements.each do |statement|
      str = "#{str}\n statement #{statement.printCollectedData(2)}"
    end
    return str
  end
end