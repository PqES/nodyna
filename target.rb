class Calculator
  const_set(:pi, 3.14)

  def op(opName, a, b)
    send(opName, a, b)
    send(:hi)
  end

  def +(a, b)
    return a + b
  end

  def -(a, b)
    return a - b
  end

  def *(a, b)
    return a * b
  end

  def /(a, b)
    return a / b
  end

end

calc = Calculator.new
calc.class.const_set(:EPSLON, 2.71432)
epslon = calc.class.const_get(:EPSLON)
pi = calc.class.const_get(:PI)
puts calc.op(:+, 3, 2)
puts calc.op(:-, 3, 2)
puts calc.op(:*, 3, 2)
puts calc.op(:/, 3, 2)
puts epslon * pi

