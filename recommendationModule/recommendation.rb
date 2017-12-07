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

  def initValues()
    @totalDynamicStatements = {}
    @safeRecommendations = {}
    @unsafeRecommendations = {}
    [:class_variable_get, :class_variable_set, :const_set, :const_get,
    :instance_variable_set, :instance_variable_get, :send].each do |dynamicStatement|
      @totalDynamicStatements[dynamicStatement] = 0
      @safeRecommendations[dynamicStatement] = 0
      @unsafeRecommendations[dynamicStatement] = 0
    end
  end

  def printResults()
    puts "Resultado Geral:"
    [:class_variable_get, :class_variable_set, :const_set, :const_get,
     :instance_variable_set, :instance_variable_get, :send].each do |dynamicStatement|
      puts "#{dynamicStatement}: #{@totalDynamicStatements[dynamicStatement]}; Safes: #{@safeRecommendations[dynamicStatement]}; Unsafes: #{@unsafeRecommendations[dynamicStatement]}"
    end
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
      puts "#{function.methodName} indetificado no arquivo #{function.rbfile} linha #{function.line}"
      @totalDynamicStatements[function.methodName] += 1
      success, safeRecommendation, msg = self.send(functionToCall, linkedFunction, root, function)
      if(success)
        if(safeRecommendation)
          @safeRecommendations[function.methodName] += 1
          puts "Sugestao [safe]:\n#{msg}"
        else
          @unsafeRecommendations[function.methodName] += 1
          puts "Sugestao [unsafe]:\n#{msg}"
        end
      else
        puts "#{msg}"
      end
      puts "#{"=" * 80}"
    end
  end


end