require_relative "inferable"
require_relative "basic_data"

class ConstantDef < BasicData

  include Inferable
  attr_reader :name
  attr_writer :private

  def initialize(rbfile, line, exp, name)
    super(rbfile, line, exp)
    initInferableModule()
    @name = name
    @private = false
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def isPrivate?()
    return @private
  end

  def to_s
    return @name
  end

  def printCollectedData()
    return "#{@name} #{printInferData}"
  end
end