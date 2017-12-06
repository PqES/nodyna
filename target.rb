class Test
  def main()
    x = :PI
    obj = Test
    Test.const_get(:PI)
    Test.const_get(x)
    obj.const_get(:PI)
    obj.const_get(x)
  end
end