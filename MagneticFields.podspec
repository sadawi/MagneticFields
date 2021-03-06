Pod::Spec.new do |s|
  s.name             = "MagneticFields"
  s.version          = "0.6.7"
  s.summary          = "Type-safe model fields with validation and observation"
  s.homepage         = "https://github.com/sadawi/MagneticFields"
  s.license          = 'MIT'
  s.author           = { "Sam Williams" => "samuel.williams@gmail.com" }
  s.source           = { :git => "https://github.com/sadawi/MagneticFields.git", :tag => s.version.to_s }

  s.platforms       = { :ios => '8.0', :watchos => '2.0' }
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
