require_relative "processors/ast_generator"
require_relative "processors/class_process"
require_relative "inferModule/inference"
require_relative "recommendationModule/recommendation"
require_relative "collectedDatas/structures/class_def"
require_relative "collectedDatas/discovered_classes"

defaultClazz = ClassDef.new(nil, nil, nil, "#DefaultClass".to_sym, "#DefaultClass".to_sym)
DiscoveredClasses.instance.addClass(defaultClazz)
target = "/home/elderjr/Documents/git_repositories/nodyna/target.rb"
ast = ASTGenerator.generate(target)
puts ast.to_s
ClassProcess.new.initProcess(ast, target)
Inference.infer()
Recommendation.instance.recommend()
#Recommendation.instance.printResults()
puts "Classes Descobertas: "
DiscoveredClasses.instance.classes.each do |className, clazz|
  puts clazz.printCollectedData()
end
