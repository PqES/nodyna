require_relative "../basic_data"
require_relative "infer_data"
require_relative "inference_set"
require_relative "infer_data"
require "set"

module Inferable

  def initInferableModule()
    @inferenceSet = InferenceSet.new()
    @listeners = Set.new()
  end

  def createInfer(type, value)
    return InferData.new(type, value, self)
  end

  def infers()
    return @inferenceSet.infers()
  end

  def addListener(obj)
    @listeners << obj
    obj.onReceiveNotification(self)
  end

  def onReceiveNotification(obj)
    raise "method onReceiveNotification not implemented in #{self.class}"
  end

  def notifyNewInfers()
    @listeners.each do |listener|
      listener.onReceiveNotification(self)
    end
  end

  def addAllInfer(infers)
    newInfers = @inferenceSet.addAllInfer(infers)
    if(newInfers)
      notifyNewInfers()
    end
  end

  def addInfer(infer)
    newInfers = @inferenceSet.addInfer(infer)
    if(newInfers)
      notifyNewInfers()
    end
  end

  def printInferData()
    strType = "{"
    strValue = "{"
    inferableBy = nil
    if(@inferenceSet.infers.size > 0)
      @inferenceSet.infers.each do |inferData|
        strType = "#{strType}#{inferData.type},"
        strValue = "#{strValue}#{inferData.value},"
      end
      strType.chop!
      strValue.chop!
    end
    strType = "#{strType}}"
    strValue = "#{strValue}}"
    return "[#{strType},#{strValue}]"
  end

end