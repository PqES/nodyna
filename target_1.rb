class Test
  @@a
  CONST = 3
  attr_accessor :a
  def testConstSet()
    x = :E
    obj = Test
    Test.const_set(:E, 2.71)
    Test.const_set(x, 2.71)
    obj.const_set(:E, 2.71)
    obj.const_set(x, 2.71)
  end

  def testConstGet()
    obj = Test
    x = :CONST
    Test.const_get(:CONST)
    Test.const_get(x)
    obj.const_get(:CONST)
    obj.const_get(x)
  end

  def testInstanceVariableGet()
    obj = Test.new
    x = :@a
    instance_variable_get(:@a)
    instance_variable_get(x)
    obj.instance_variable_get(:@a)
    obj.instance_variable_get(x)
  end

  def testInstanceVariableSet()
    obj = Test.new
    x = :@a
    instance_variable_set(:@a, 2)
    instance_variable_set(x, 2)
    obj.instance_variable_set(:@a, 2)
    obj.instance_variable_set(x, 2)
  end

  def self.a=

  end
  def self.testClassVariableSet()
    obj = Test
    x = :@@a
    class_variable_set(:@@a, 2)
    class_variable_set(x, 2)
    obj.class_variable_set(:@@a, 2)
    obj.class_variable_set(x, 2)
  end

  def self.testClassVariableGet()
    obj = Test
    x = :@@a
    class_variable_get(:@@a)
    class_variable_get(x)
    obj.class_variable_get(:@@a)
    obj.class_variable_get(x)
  end

  def testSend()
    obj = Test
    method = :testClassVariableGet
    obj.send(:testClassVariableGet)
    obj.send(method)
  end
end