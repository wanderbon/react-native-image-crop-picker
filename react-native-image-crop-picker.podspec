package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name             = "react-native-image-crop-picker"
  s.version          = package['version']
  s.summary          = package["description"]
  s.requires_arc = true
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/wanderbon/react-native-image-crop-picker'
  s.authors      = { "Alexander Blokhin" => "a.blokhin@rambler-co.ru" }
  s.source       = { :git => "https://github.com/wanderbon/react-native-image-crop-picker", :tag => "v#{s.version}"}
  s.source_files = 'ios/**/*.{h,m,swift}'
  s.platform     = :ios, "10.0"

  s.dependency "React"

  s.subspec 'RGImagePicker' do |qb|
    qb.name             = "RGImagePicker"
    qb.resource_bundles = { "RGImagePicker" => "ios/RGImagePicker/Resources/*.{lproj,storyboard}" }
    qb.requires_arc     = true
    qb.frameworks       = "Photos"
  end
end
