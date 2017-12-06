require "set"
class InferenceSet

  attr_reader :infers

  def initialize()
    @infers = Set.new
  end

  def size
    return infers.size
  end

  def addInfer(infer)
    oldSize = @infers.size
    @infers << infer
    return @infers.size > oldSize
  end

  def addAllInfer(infers)
    oldSize = @infers.size
    @infers = @infers.merge(infers)
    return @infers.size > oldSize
  end
end