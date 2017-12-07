require_relative "../../collectedDatas/infers/inferable"
require_relative "dynamic_values"
class Variable < BasicData
  include Inferable
  include DynamicValues

  attr_reader :name
  attr_writer :hasGetter, :hasSetter

  def initialize(rbfile, line, exp, name)
    super(rbfile, line, exp)
    initInferableModule()
    @name = name
    @hasGetter = false
    @hasSetter = false
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def hasGetter?
    return @hasGetter
  end

  def hasSetter?
    return @hasSetter
  end

  def to_s
    return @name
  end

  def printCollectedData()
    return "#{@name} #{printInferData}"
  end
end