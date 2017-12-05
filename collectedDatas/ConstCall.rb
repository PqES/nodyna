require_relative "inferable"
require_relative "infer_data"
require_relative "../collectedDatas/discovered_classes"
require_relative "../collectedDatas/self_instance"
class ConstCall < BasicData
  include Inferable
  def initialize(rbfile, line, exp, values, classContext)
    super(rbfile, line, exp)
    initInferableModule()
    @values = values
    @fullName = generateName(@values.size - 1)
    @classContext = classContext
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def generateName(lastIndex)
    name = ""
    if(@values.size > 0)
      for i in 0..lastIndex
        if(i < @values.size)
          name = "#{name}#{@values[i]}::"
        end
      end
      name.chop!
      name.chop!
    end
    return name.to_sym()
  end

  def infer()
    clazz = DiscoveredClasses.instance.getClassByFullName(@fullName)
    constantWithFullName = @classContext.getConstantByName(@fullName)
    innerClazz = DiscoveredClasses.instance.getClassByFullName("#{@classContext.fullName}::#{@fullName}".to_sym())
    if(!clazz.nil?)
      addAllInfer(SelfInstance.new(clazz.fullName).infers)
    elsif(!constantWithFullName.nil?)
      constantWithFullName.addListener(self)
    elsif (!innerClazz.nil?)
      addAllInfer(SelfInstance.new(innerClazz.fullName).infers)
    else
      clazz = DiscoveredClasses.instance.getClassByFullName("#{@classContext.fullName}::#{generateName(@values.size - 2)}")
      if(!clazz.nil?)
        constantWithAlias = clazz.getConstantByName(@values.last)
        constantWithAlias.addListener(self) if !constantWithAlias.nil?
      end
    end
  end

  def to_s
    return @fullName
  end

  def printCollectedData()
    return "#{@fullName} #{printInferData}"
  end
end