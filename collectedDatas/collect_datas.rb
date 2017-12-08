require_relative "structures/class_def"
require_relative "discovered_classes"
require_relative "../processors/ast_generator"
require_relative "../processors/class_process"
class CollectDatas

  def self.collect(paths)
    defaultClazz = ClassDef.new(nil, nil, nil, "#DefaultClass".to_sym, "#DefaultClass".to_sym)
    DiscoveredClasses.instance.addClass(defaultClazz)
    paths.each do |path|
      begin
        ast = ASTGenerator.generate(path)
        success = true
      rescue
        success = false
      end
      if(success)
        puts ast.to_s if $debug
        ClassProcess.new.initProcess(ast, path)
      end
    end
    return DiscoveredClasses.instance.getAllClasses()
  end
end