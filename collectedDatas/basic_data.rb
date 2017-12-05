class BasicData

  attr_reader :rbfile, :line, :exp

  def initialize(rbfile, line, exp)
    @rbfile = rbfile
    @line = line
    @exp = exp
  end

end