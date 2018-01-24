class Calculator

  def sum(a, b)
    return a + b
  end
  def sub(a,b)
    return a - b
  end

  def op(opName, a, b)
    send(opName, a, b)
  end
end

Calculator.new.op(:sum, a, b)
Calculator.new.op(:sub, a, b)