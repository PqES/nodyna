require_relative "collectedDatas/collect_datas"
require_relative "inferModule/inference"
require_relative "recommendationModule/recommendation"
require_relative "util"

$debug = false
datasetPath = "/home/elder/Documents/git_repositories/rdf-master/dataset"
projects = {
      "Active Admin": ["#{datasetPath}//activeadmin/**/lib/**/*.rb"],
      "Cancan": ["#{datasetPath}//cancan/**/lib/**/*.rb"],
      "Capistrano": ["#{datasetPath}//capistrano/**/lib/**/*.rb"],
      "Capybara": ["#{datasetPath}//capybara/**/lib/**/*.rb"],
      "Carrierwave": ["#{datasetPath}//carrierwave/**/lib/**/*.rb"],
      "CocoaPods": ["#{datasetPath}/cocoaPods/**/lib/**/*.rb"],
      "Devdocs": ["#{datasetPath}//devdocs/**/lib/**/*.rb"],
      "Devise": ["#{datasetPath}/devise/**/lib/**/*.rb", "#{datasetPath}//devise/**/app/**/*.rb"],
      "Diaspora": ["#{datasetPath}//diaspora/**/lib/**/*.rb", "#{datasetPath}/diaspora/app/**/*.rb", "#{datasetPath}/diaspora/config/**/*.rb"],
      "Discourse": ["#{datasetPath}//discourse/**/lib/**/*.rb", "#{datasetPath}//dataset/discourse/app/**/*.rb", "#{datasetPath}//discourse/config/**/*.rb"],
      "FPM": ["#{datasetPath}/fpm/**/lib/**/*.rb"],
      "GitLab": ["#{datasetPath}/gitlabhq/**/lib/**/*.rb", "#{datasetPath}/gitlabhq/app/**/*.rb", "#{datasetPath}/gitlabhq/config/**/*.rb"],
      "Grape": ["#{datasetPath}/grape/**/lib/**/*.rb"],
      "Homebrew": ["#{datasetPath}/homebrew/**/lib/**/*.rb"],
      "Homebrew-Cask": ["#{datasetPath}/homebrew-cask/**/lib/**/*.rb"],
      "Huginn": ["#{datasetPath}/huginn/**/lib/**/*.rb", "#{datasetPath}/huginn/**/app/**/*.rb"],
      "Jekyll": ["#{datasetPath}/jekyll/**/lib/**/*.rb"],
      "Octopress": ["#{datasetPath}/octopress/**/plugins/**/*.rb"],
      "Paperclip": ["#{datasetPath}/paperclip/**/lib/**/*.rb"],
      "Rails": ["#{datasetPath}/rails/**/lib/**/*.rb"],
      "Rails Admin": ["#{datasetPath}/rails_admin/**/lib/**/*.rb"],
      "Resque": ["#{datasetPath}/resque/**/lib/**/*.rb"],
      "Ruby": ["#{datasetPath}/ruby/**/lib/**/*.rb"],
      "Sass": ["#{datasetPath}/sass/**/lib/**/*.rb"],
      "Simple Form": ["#{datasetPath}/simple_form/**/lib/**/*.rb"],
      "Spree": ["#{datasetPath}/spree/**/lib/**/*.rb", "#{datasetPath}/spree/api/**/*.rb", "#{datasetPath}/spree/backend/**/*.rb", "#{datasetPath}/spree/core/**/*.rb"],
      "Vagrant": ["#{datasetPath}/vagrant/**/lib/**/*.rb"],
      "Whenever": ["#{datasetPath}/whenever/**/lib/**/*.rb"]
}

locs = 0
projects.each do |projectName, files|
  targets = Util.extractFiles(files)
  DiscoveredClasses.instance.clear()
  puts "Collecting datas (#{projectName})..."
  CollectDatas.collect(targets)
  puts "Making infers..."
  Inference.infer()
  Recommendation.instance.recommend()
  #Recommendation.instance.printRecommendations()
  Recommendation.instance.printGeneralResults()
  locs += Recommendation.instance.loc
end
puts "Total Loc: #{locs}"
puts "Loc average: #{locs / projects.size}" 
if($debug)
  puts "Classes Descobertas: "
  DiscoveredClasses.instance.classes.each do |className, clazz|
    puts clazz.printCollectedData()
  end
end

