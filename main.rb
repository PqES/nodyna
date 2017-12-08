require_relative "collectedDatas/collect_datas"
require_relative "inferModule/inference"
require_relative "recommendationModule/recommendation"
require_relative "util"

$debug = false
projects = {
  "Test": ["/home/elderjr/Documents/git_repositories/nodyna/target_1.rb"],
  #"Active Admin": ["/home/elderjr/Documents/git_repositories/rdf/dataset/activeadmin/**/lib/**/*.rb"],
  #"Cancan": ["/home/elderjr/Documents/git_repositories/rdf/dataset/cancan/**/lib/**/*.rb"],
  #"Capistrano": ["/home/elderjr/Documents/git_repositories/rdf/dataset/capistrano/**/lib/**/*.rb"],
  #"Capybara": ["/home/elderjr/Documents/git_repositories/rdf/dataset/capybara/**/lib/**/*.rb"],
  #"Carrierwave": ["/home/elderjr/Documents/git_repositories/rdf/dataset/carrierwave/**/lib/**/*.rb"],
  #"CocoaPods": ["/home/elderjr/Documents/git_repositories/rdf/dataset/cocoaPods/**/lib/**/*.rb"],
  #"Devdocs": ["/home/elderjr/Documents/git_repositories/rdf/dataset/devdocs/**/lib/**/*.rb"],
  #"Devise": ["/home/elderjr/Documents/git_repositories/rdf/dataset/devise/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/devise/**/app/**/*.rb"],
  #"Diaspora": ["/home/elderjr/Documents/git_repositories/rdf/dataset/diaspora/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/diaspora/app/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/diaspora/config/**/*.rb"],
  #"Discourse": ["/home/elderjr/Documents/git_repositories/rdf/dataset/discourse/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/discourse/app/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/discourse/config/**/*.rb"],
  #"FPM": ["/home/elderjr/Documents/git_repositories/rdf/dataset/fpm/**/lib/**/*.rb"],
  #"GitLab": ["/home/elderjr/Documents/git_repositories/rdf/dataset/gitlabhq/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/gitlabhq/app/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/gitlabhq/config/**/*.rb"],
  #"Grape": ["/home/elderjr/Documents/git_repositories/rdf/dataset/grape/**/lib/**/*.rb"],
  #"Homebrew": ["/home/elderjr/Documents/git_repositories/rdf/dataset/homebrew/**/lib/**/*.rb"],
  #"Homebrew-Cask": ["/home/elderjr/Documents/git_repositories/rdf/dataset/homebrew-cask/**/lib/**/*.rb"],
  #"Huginn": ["/home/elderjr/Documents/git_repositories/rdf/dataset/huginn/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/huginn/**/app/**/*.rb"],
  #"Jekyll": ["/home/elderjr/Documents/git_repositories/rdf/dataset/jekyll/**/lib/**/*.rb"],
  #"Octopress": ["/home/elderjr/Documents/git_repositories/rdf/dataset/octopress/**/plugins/**/*.rb"],
  #"Paperclip": ["/home/elderjr/Documents/git_repositories/rdf/dataset/paperclip/**/lib/**/*.rb"],
  #"Rails": ["/home/elderjr/Documents/git_repositories/rdf/dataset/rails/**/lib/**/*.rb"],
  #"Rails Admin": ["/home/elderjr/Documents/git_repositories/rdf/dataset/rails_admin/**/lib/**/*.rb"],
  #"Resque": ["/home/elderjr/Documents/git_repositories/rdf/dataset/resque/**/lib/**/*.rb"],
  #"Ruby": ["/home/elderjr/Documents/git_repositories/rdf/dataset/ruby/**/lib/**/*.rb"],
  #"Sass": ["/home/elderjr/Documents/git_repositories/rdf/dataset/sass/**/lib/**/*.rb"],
  #"Simple Form": ["/home/elderjr/Documents/git_repositories/rdf/dataset/simple_form/**/lib/**/*.rb"],
  #"Spree": ["/home/elderjr/Documents/git_repositories/rdf/dataset/spree/**/lib/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/spree/api/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/spree/backend/**/*.rb", "/home/elderjr/Documents/git_repositories/rdf/dataset/spree/core/**/*.rb"],
  #"Vagrant": ["/home/elderjr/Documents/git_repositories/rdf/dataset/vagrant/**/lib/**/*.rb"],
  #"Whenever": ["/home/elderjr/Documents/git_repositories/rdf/dataset/whenever/**/lib/**/*.rb"]
}

projects.each do |projectName, files|
  targets = Util.extractFiles(files)
  puts projectName
  DiscoveredClasses.instance.clear()
  puts "Collecting datas..."
  CollectDatas.collect(targets)
  puts "Making infers..."
  Inference.infer()
  Recommendation.instance.recommend()
  Recommendation.instance.printRecommendations()
  Recommendation.instance.printGeneralResults()
  puts "#{"="*80}"
end

if($debug)
  puts "Classes Descobertas: "
  DiscoveredClasses.instance.classes.each do |className, clazz|
    puts clazz.printCollectedData()
  end
end

