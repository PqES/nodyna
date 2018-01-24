require "singleton"
class DiscoveredClasses
  include Singleton
  attr_reader :classes
  def initialize()
    @classes =  {}
  end

  def clear()
    @classes.clear()
  end

  def getClassByFullName(name)
    name = "#{name}".to_sym()
    if(@classes.has_key?(name))
      return @classes[name]
    end
    return nil
  end

  def addClass(clazz)
    @classes[clazz.fullName] = clazz
  end

  def getAllClasses()
    return @classes
  end

end