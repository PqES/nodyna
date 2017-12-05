class Test
  def main()
    x = Test.new()
    x.class.const_set(:pi, 3.14)
  end
end