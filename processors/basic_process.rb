require 'sexp_processor'
class BasicProcess < SexpInterpreter

  def initialize()
    super()
    self.default_method = "default_process"
    self.warn_on_default = false
  end

  def default_process(exp)
    exp.each_sexp do |sexp|
      process(sexp)
    end
  end
end