require_relative "processors/ast_generator"
require_relative "processors/class_process"
require_relative "inferModule/inference"
require_relative "recommendationModule/recommendation"

target = "/home/elderjr/Documents/ruby_workspace/nodyna/target.rb"
ast = ASTGenerator.generate(target)
puts ast.to_s
ClassProcess.new.initProcess(ast, target)
Inference.infer()
Recommendation.recommend()
puts "Classes Descobertas: "
DiscoveredClasses.instance.classes.each do |className, clazz|
  puts clazz.printCollectedData()
end