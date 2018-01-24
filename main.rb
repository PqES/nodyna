require_relative "collectedDatas/collect_datas"
require_relative "inferModule/inference"
require_relative "recommendationModule/recommendation"
require_relative "util"
$debug = false
files = ["/home/elderjr/Documents/git_repositories/nodyna/target_1.rb"]
targets = Util.extractFiles(files)
DiscoveredClasses.instance.clear()
puts "Collecting datas..."
CollectDatas.collect(targets)
puts "Making infers..."
Inference.infer()
Recommendation.instance.recommend()
Recommendation.instance.printRecommendations()
Recommendation.instance.printGeneralResults()
puts "#{"="*80}"
if($debug)
  puts "Classes Descobertas: "
  DiscoveredClasses.instance.classes.each do |className, clazz|
    puts clazz.printCollectedData()
  end
end

