class InferData
  attr_reader :type, :value, :obj

  def initialize(type, value, obj)
    @type = type
    @value = value
    @obj = obj
  end


  def isObjectInstance?()
    return obj.class != SelfInstance
  end

  def isFromArray?()
    return obj.class == ArrayDef
  end

  def eql?(inferData)
    if(inferData.class == InferData)
      return @type == inferData.type && @value == inferData.value
    end
    return false
  end

  def hash()
    @value.hash
  end

end