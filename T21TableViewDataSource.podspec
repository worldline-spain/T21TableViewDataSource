
Pod::Spec.new do |s|

  s.name         = "T21TableViewDataSource"
  s.version      = "1.0.0"
  s.summary      = "The TableViewDataSource class is a helper class to manage TableView data manipulations like additions, deletions and updates. It offers an easy way to update the tableview datasource, applying a concrete sorting and avoiding item duplications when adding already existing entities into the datasource."
  s.author    = "Eloi Guzman Ceron"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/worldline-spain/T21TableViewDataSource.git", :tag => "1.0.0" }
  s.source_files  = "src/**/*.{swift}"
  s.framework  = "Foundation", "UIKit"
  s.requires_arc = true

end
