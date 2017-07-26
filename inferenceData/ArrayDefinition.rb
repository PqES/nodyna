class ArrayDefinition < StaticDefinition

  def initialize(relatedFile,relatedExp, value)
    super(relatedFile,relatedExp, value)
    @arrayValues = value
    @inference.addType(value.class)
    @inference.addValue(self)
  end
 
  def addValues(values)
    values.each do |v|
      if(!@arrayValues.include?(v))
        @arrayValues << v
      end
    end
  end

  def to_s
    str = "["
    @value.each do |v|
      str = "#{str} #{v.to_s},"
    end
    if(str.size > 1)
      str.chomp!(',')
    end
    str += "]"
    return str
  end

  
end 
