class LiteralDefinition < StaticDefinition

  def initialize(relatedFile,relatedExp, value)
    super(relatedFile,relatedExp, value)
    @inference.addType(value.class)
    @inference.addValue(self)
  end
    
  def to_s
    if(@value.class == Symbol)
      return ":#{value}"
    elsif(@value.class == String)
      return "\"#{value}\""
    else
      return "#{value}"
    end
  end
end
