require 'ruby_parser'
require 'sexp_processor'
require 'set'
require_relative 'process/ASTGenerator'
require_relative 'process/BasicProcess'
require_relative 'process/MainProcess'
require_relative 'process/ClassProcess'
require_relative 'process/MethodProcess'
require_relative 'process/ParamProcess'
require_relative 'process/VarAssignmentProcess'
require_relative 'process/LinkedFunctionProcess'
require_relative 'process/IterationProcess'
require_relative 'process/ArrayProcess'
require_relative 'process/ImplicitReturn'
require_relative 'process/ProcessUtil'
require_relative 'inferenceData/Inference'
require_relative 'inferenceData/InferData'
require_relative 'inferenceData/BasicDefinition'
require_relative 'inferenceData/ScopeDefinition'
require_relative 'inferenceData/StaticDefinition'
require_relative 'inferenceData/ArrayDefinition'
require_relative 'inferenceData/IterationDefinition'
require_relative 'inferenceData/ClassDefinition'
require_relative 'inferenceData/MethodDefinition'
require_relative 'inferenceData/VarDefinition'
require_relative 'inferenceData/AssignmentDefinition'
require_relative 'inferenceData/LiteralDefinition'
require_relative 'inferenceData/ConstDefinition'
require_relative 'inferenceData/FunctionCallDefinition'
require_relative 'inferenceData/ReturnDefinition'
require_relative 'inferenceData/LinkedFunctions'
require_relative 'inferenceData/Infer'
require_relative 'inferenceData/Recommendation'

def extractFiles(pathes)
  files = []
  pathes.each do |path|
    files += Dir.glob(path)
  end
  files.flatten!
  return files
end

#../dataset/homebrew/lib/Homebrew/cmd/install.rb.144.send MEDIUM ex2.ID:send-21
#../dataset/homebrew/lib/Homebrew/cmd/uses.rb.23.send MEDIUM ex2.ID:send-9
#../dataset/homebrew/lib/Homebrew/cmd/uses.rb.27.send MEDIUM ex2.ID:send-10
#../dataset/homebrew/lib/Homebrew/cmd/uses.rb.34.send MEDIUM ex2.ID:send-11
#../dataset/homebrew/lib/Homebrew/cmd/uses.rb.38.send MEDIUM ex2.ID:send-12
#../dataset/homebrew/lib/Homebrew/cmd/deps.rb.40.send MEDIUM ex2.ID:send-15
#../dataset/homebrew/lib/Homebrew/cmd/deps.rb.44.send MEDIUM ex2.ID:send-16
#../dataset/homebrew/lib/Homebrew/cmd/deps.rb.49.send MEDIUM ex2.ID:send-17
#../dataset/homebrew/lib/Homebrew/cmd/deps.rb.53.send MEDIUM ex2.ID:send-18
#../dataset/homebrew/lib/Homebrew/cmd/info.rb.133.send MEDIUM ex2.ID:send-8
#../dataset/homebrew/lib/Homebrew/cmd/audit.rb.142.send MEDIUM ex2.ID:send-23
#../dataset/homebrew/lib/Homebrew/cmd/audit.rb.494.send MEDIUM ex2.ID:send-24
#../dataset/homebrew/lib/Homebrew/cmd/audit.rb.511.send MEDIUM ex2.ID:send-25
#../dataset/homebrew/lib/Homebrew/cmd/fetch.rb.98.send MEDIUM ex2.ID:send-22

targets = []
targets << "/home/elderjr/Documents/git_repositories/nodyna/target.rb"

#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/homebrew/**/lib/Homebrew/cmd/audit.rb"

#Homebrew
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/homebrew/**/lib/**/*.rb"

#Diaspora
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/diaspora/**/lib/**/*.rb"
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/diaspora/app/**/*.rb"
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/diaspora/config/**/*.rb"

#Active Admin
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/activeadmin/**/lib/**/*.rb"

#Discourse
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/discourse/**/lib/**/*.rb"
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/discourse/app/**/*.rb"
#targets << "/home/elderjr/Documents/git_repositories/nodyna/dataset/discourse/config/**/*.rb"

files = extractFiles(targets)
classes = {}
classes["DefaultClassNodyna"] = ClassDefinition.new(nil,nil, "DefaultClassNodyna")
#passos
files.each do |file|
  puts "Collecting data from #{file}"
  #begin
    ast = ASTGenerator.generate(file) #geração das ast
    #puts ast.to_s
    classes.merge!(MainProcess.new(file).initProcess(classes, ast)) #coleta de dados
  #rescue
    #next
  #end
end

Infer.infer(classes) #inferencia
Recommendation.makeRecommendations(classes) #aplicação das heurísticas

#exibição dos resultados
if(ARGV.include?("--show_infers"))
  classes.each do |clazzName, clazz|
    puts "Class: #{clazzName}"
    clazz.statements.each do |statement|
      puts "  #{statement.to_s} -> #{statement.infers_str}, #{statement.values_str}"
    end
    clazz.staticMethods.each do |methodName, method|
      puts "  #{methodName}(static)"
      method.statements.each do |statement|
        puts "  #{statement.to_s} -> #{statement.infers_str}, #{statement.values_str}"
      end
    end
    clazz.methods.each do |methodName, method|
      puts "  #{methodName}(instance) -> #{method.infers_str}, #{method.values_str}"
      method.statements.each do |statement|
        puts "    #{statement.to_s} -> #{statement.infers_str}, #{statement.values_str}"
      end
      method.variables.each do |varName, var|
        puts "    #{var.to_s} -> #{var.infers_str}, #{var.values_str}"
      end
    end
  end
end 
