require_relative "../collectedDatas/discovered_classes"
require_relative "../collectedDatas/structures/class_def"
require_relative "basic_process"
require_relative "method_process"
require_relative "../collectedDatas/dynamicValues/constant_def"

class ClassProcess < BasicProcess

  def initProcess(ast, relatedFile)
    @visibility = :public
    @relatedFile = relatedFile
    @classStack = []
    @currentClass = nil
    process(ast)
  end

  def process_class(exp)
    _, className, *args = exp
    if(@classStack.size > 0)
      fullName = "#{@classStack.last.fullName}::#{className}"
      clazz = ClassDef.new(@relatedFile, exp.line, exp, className, fullName)
      @classStack.last.addInnerClass(clazz)
    else
      clazz = ClassDef.new(@relatedFile, exp.line, exp, className, className)
    end
    DiscoveredClasses.instance.addClass(clazz)
    @currentClass = clazz
    @classStack.push(clazz)
    args.map {|subTree| process(subTree) if subTree.class == Sexp}
    @classStack.pop()
    @currentClass = @classStack.last
  end

  def process_module(exp)
    process_class(exp)
  end

  def processMethod(exp)
    if(!@currentClass.nil?)
      method = MethodProcess.new.initProcess(exp, @relatedFile, @currentClass)
      method.visibility = @visibility
      if(method.instanceMethod)
        @currentClass.addInstanceMethod(method)
      else
        @currentClass.addStaticMethod(method)
      end
    end
  end

  def process_defn(exp)
    processMethod(exp)
  end

  def process_defs(exp)
    processMethod(exp)
  end

  def changeMethodVisibility(methodName, params)
    if(params.size == 0)
      @visibility = methodName
    else
      params.each do |param|
        if(param[0] == :lit || param[0] == :str)
          method = @currentClass.getInstanceMethodByName(param[1])
          if(!method.nil?)
            method.visibility = methodName
          end
        end
      end
    end
  end

  def changeVariableVisibility(methodName, params)
    hasGetter = false
    hasSetter = false
    if(methodName == :attr_reader)
      hasGetter = true
    elsif(methodName == :attr_writer)
      hasSetter = true
    else
      hasGetter = true
      hasSetter = true
    end
    params.each do |param|
      if(param[0] == :lit || param[0] == :str)
        varName = "@#{param[1]}".to_sym()
        variable = @currentClass.getInstanceVariableByName(varName)
        if(variable.nil?)
          variable = Variable.new(@relatedFile, param.line, param, varName)
          @currentClass.addInstanceVariable(variable)
        end
        variable.hasGetter = variable.hasGetter? || hasGetter
        variable.hasSetter = variable.hasSetter? || hasSetter
      end
    end
  end

  def changeConstantVisibility(consts)
    consts.each do |constExp|
      if(constExp[0] == :lit || constExp[0] == :str)
        const = @currentClass.getConstantByName(constExp[1])
        if(!const.nil?)
          const.private = true
        end
      end
    end
  end

  def process_call(exp)
    _, root, methodName, *params = exp
    if([:private, :protected, :public].include?(methodName))
      changeMethodVisibility(methodName, params)
    elsif([:attr_reader, :attr_writer, :attr_accessor].include?(methodName))
      changeVariableVisibility(methodName, params)
    elsif(methodName == :private_constant)
      changeConstantVisibility(params)
    else
      linkedFunction = LinkedFunctionProcess.new.initProcess(exp, @relatedFile, @currentClass, nil)
      @currentClass.addStatement(linkedFunction)
    end
  end

  def process_cdecl(exp)
    _, constName, expValue = exp
    if(constName.class == Symbol)
      constant = ConstantDef.new(@relatedFile, exp.line, exp, constName)
      value = UtilProcess.getValue(expValue, @relatedFile, @currentClass, nil)
      if(!value.nil?)
        value.addListener(constant)
      end
      @currentClass.addConstant(constant)
    end
  end

  def process_ivar(exp)
    _, varName = exp
    variable = Variable.new(@relatedFile, exp.line, exp, varName)
    @currentClass.addInstanceVariable(variable)
  end

  def process_cvar(exp)
    _, varName = exp
    variable = Variable.new(@relatedFile, exp.line, exp, varName)
    @currentClass.addStaticVariable(variable)
  end
end