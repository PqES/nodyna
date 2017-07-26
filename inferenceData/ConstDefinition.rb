class ConstDefinition < StaticDefinition


  def initialize(relatedFile,relatedExp, value)
    super(relatedFile,relatedExp, value)
    @inference.addType("Class")
    @inference.addValue(self)
  end
    
  def to_s
    return "#{value}"
  end
end
