require 'ruby_parser'
require 'sexp_processor'
require 'set'
require_relative 'process/ASTGenerator'
require_relative 'process/MainProcess'
require_relative 'process/MethodProcess'
require_relative 'process/ParamProcess'
require_relative 'process/VarAssignmentProcess'
require_relative 'process/LinkedFunctionProcess'
require_relative 'process/ProcessUtil'
require_relative 'inferenceData/InferData'
require_relative 'inferenceData/ClassDefinition'
require_relative 'inferenceData/MethodDefinition'
require_relative 'inferenceData/VarDefinition'
require_relative 'inferenceData/AssignmentDefinition'
require_relative 'inferenceData/ValueDefinition'
require_relative 'inferenceData/FunctionCallDefinition'
require_relative 'inferenceData/ReturnDefinition'
require_relative 'inferenceData/LinkedFunctions'
require_relative 'inferenceData/Infer'
require_relative 'inferenceData/Recommendation'

ast = ASTGenerator.generate("/home/elder/Documents/Aptana Studio 3 Workspace/TypeInference/target.rb")
mainProcess = MainProcess.new
puts(ast.to_s)
puts "#{'='*30}   Coleta de dados   #{'='*29}"
classes = mainProcess.initProcess(ast)
puts "#{'='*32}   Inferência   #{'='*31}"
Infer.infer(classes)
puts "#{'='*31}   Recomendações   #{'='*30}"
Recommendation.makeRecommendations(classes)
puts "#{'='*80}"
 
