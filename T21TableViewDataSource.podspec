Pod::Spec.new do |s|
  s.name                    = "T21TableViewDataSource"
  s.version                 = "2.0.0"
  s.summary                 = "The TableViewDataSource class is a helper class to manage TableView data manipulations."
  s.author                  = "Eloi Guzman Ceron"
  s.platform                = :ios
  s.ios.deployment_target   = "10.0"
  s.source                  = { :git => "https://github.com/worldline-spain/T21TableViewDataSource.git", :tag => "2.0.0" }
  s.source_files            = "src/**/*.{swift}"
  s.framework               = "Foundation", "UIKit"
  s.requires_arc            = true
  s.homepage                = "https://github.com/worldline-spain/T21TableViewDataSource"
  s.license                 = "https://github.com/worldline-spain/T21TableViewDataSource/blob/master/LICENSE"
  s.swift_version           = '5.0'
end
