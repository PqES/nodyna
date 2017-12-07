class Test
  def initialize
    @@a
    obj = Test
    x = :@@a
    x = :@@b
    Test.class_variable_set(:@@a, 2)
    obj.class_variable_set(:@@a, 2)
    Test.class_variable_set(x, 2)
    obj.class_variable_set(x, 2)
  end

  def self.a=

  end
end