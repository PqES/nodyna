class ImplicitReturn

 def self.get_last_stm(exp)
   if(exp.class == Array || exp[0] == :if || exp[0] == :block)
     last_stm = exp
     if(exp.respond_to?:each_sexp)
       exp.each_sexp do |stm|
         last_stm = stm
       end
     else
       exp.each do |stm|
         if(stm.class == Sexp)
           last_stm = stm
         end
       end
              end
              return last_stm
            else
              return exp
            end
          end
          
          def self.check_implicit_return_if(exp)
            _, condition, true_body, else_body = exp
            implicit_returns = []
            if(!true_body.nil?)
              last_stm = get_last_stm(true_body)
              implicit_returns.concat(check_implicit_return(last_stm))
            end
            if(!else_body.nil?)
              last_stm = get_last_stm(else_body)
              implicit_returns.concat(check_implicit_return(last_stm))
            end
            return implicit_returns
          end
          
          def self.check_implicit_return_case(exp)
            _, _, *whens = exp  
            implicit_returns = []
            whens.each do |when_exp|
              if(!when_exp.nil?)
                last_stm = get_last_stm(when_exp)
                implicit_returns.concat(check_implicit_return(last_stm))
              end
            end
            return implicit_returns
          end
          
          def self.check_implicit_return(exp)
            if(!exp.nil?)
              if(exp[0] == :if)
                return check_implicit_return_if(exp)
              elsif(exp[0] == :case)
                return check_implicit_return_case(exp)
              else
                return [exp]
              end
            else
              return []
            end
          end
end
