#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint doraemonkit_csx.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'doraemonkit_csx'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.resources = 'Assets/*.png'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'ReactiveObjC', '~> 3.1.1'
  s.dependency 'Masonry', '~> 1.1.0'
  s.platform = :ios, '8.0'

end
