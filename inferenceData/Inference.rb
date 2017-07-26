class Inference
    attr_reader :types, :values
    
    def initialize
        @types = Set.new
        @values = Set.new
    end

    def addInfers(infer)
        oldTypesSize = @types.size
        oldValuesSize = @values.size
        @types.merge(infer.types)
        @values.merge(infer.values)
        return oldTypesSize != @types.size || oldValuesSize != @values.size
    end

    def addType(type)
        oldTypesSize = @types.size
        @types.add(type)
        return oldTypesSize != @types.size
    end

    def addValue(value)
        oldValuesSize = @values.size
        @values.add(value)
        return oldValuesSize != @values.size
    end

    def values_str()
      str = "["
      @values.each do |v|
      str += v.to_s + " "
      end
      str += "]"
      return str
    end

    def infers_str()
      return @types.to_a.to_s
    end
end