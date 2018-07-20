require "singleton"
require_relative "send_module"
require_relative "const_set_module"
require_relative "const_get_module"
require_relative "instance_variable_get_module"
require_relative "instance_variable_set_module"
require_relative "class_variable_get_module"
require_relative "class_variable_set_module"

class Recommendation
  include Singleton
  include SendModule
  include ConstSetModule
  include ConstGetModule
  include InstanceVariableGetModule
  include InstanceVariableSetModule
  include ClassVariableGetModule
  include ClassVariableSetModule

  attr_reader :totalDynamicStatements, :recommendationsCounter, :loc

  def initValues()
    @recommendations = ""
    @totalDynamicStatements = {}
    @recommendationsCounter = {}
    @loc = 0
    [:class_variable_get, :class_variable_set, :const_set, :const_get,
    :instance_variable_set, :instance_variable_get, :send].each do |dynamicStatement|
      @totalDynamicStatements[dynamicStatement] = 0
      @recommendationsCounter[dynamicStatement] = 0
    end
  end

  def printRecommendations()
    puts @recommendations
  end

  def printGeneralResults()
    [:class_variable_get, :class_variable_set, :const_set, :const_get,
     :instance_variable_set, :instance_variable_get, :send].each do |dynamicStatement|
      puts "#{dynamicStatement}: #{@recommendationsCounter[dynamicStatement]} / #{@totalDynamicStatements[dynamicStatement]}"
    end
    puts "LOC: #{@loc}"
  end

  def printLatex(projectName)
    str = "#{projectName}"
    [:class_variable_get, :class_variable_set, :const_set, :const_get,
     :instance_variable_set, :instance_variable_get, :send].each do |dynamicStatement|
      str += " & #{@recommendationsCounter[dynamicStatement]} / #{@totalDynamicStatements[dynamicStatement]}"
    end
    str += " \\\\\\hline"
    puts str
  end

  def recommend()
    initValues()
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

  def recommendLinkedFunction(statement)
    root = statement.root
    statement.functions.each do |func|
      self.recommendFunction(statement, root, func)
      root = func
    end
  end

  def recommendFunction(linkedFunction, root, function)
    functionToCall = nil
    if(function.methodName == :class_variable_get)
      functionToCall = :recommendCVG
    elsif(function.methodName == :class_variable_set)
      functionToCall = :recommendCVS
    elsif(function.methodName == :const_set)
      functionToCall = :recommendConstSet
    elsif(function.methodName == :const_get)
      functionToCall = :recommendConstGet
    elsif(function.methodName == :instance_variable_get)
      functionToCall = :recommendIVG
    elsif(function.methodName == :instance_variable_set)
      functionToCall = :recommendIVS
    elsif(function.methodName == :send)
      functionToCall = :recommendSend
    end
    if(!functionToCall.nil?)
      @recommendations << "#{function.methodName} indetificado no arquivo #{function.rbfile} linha #{function.line}\n"
      @totalDynamicStatements[function.methodName] += 1
      success, safeRecommendation, msg, loc = self.send(functionToCall, linkedFunction, root, function)
      if(success)
        @recommendationsCounter[function.methodName] += 1
        @loc += loc
        @recommendations << "Sugestao: \n#{msg}\n"
      else
        @recommendations << "#{msg}\n"
      end
      @recommendations << "#{"=" * 80}\n"
    end
  end


end
