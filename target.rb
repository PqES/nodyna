class TestClass
  
  def foo(x, y)
    if(x == 2 && y == "str1")
      sym1 = :sym1
      return sym1
    else
      sym2 = :sym2
      return sym2
    end
  end
  
  def baa(x)
    if(x == 2)
      str1 = "str1"      
      return str1
    else
      str2 = "str2"
      return str2
    end
  end
  
  def qux(x)
    if(x == 2)
      return "str"
    else
      return :sym
    end
  end
  
  def base
    y = 3
    a = TestClass.new
    funcFoo = foo(2, y)
    send("hello")
    const_get(funcFoo)
    funcBaa = baa(2)
    funcQux = qux(2)
  end
end