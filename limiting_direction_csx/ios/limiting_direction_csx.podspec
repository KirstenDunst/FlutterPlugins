#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint limiting_direction_csx.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'limiting_direction_csx'
  s.version          = '0.0.1'
  s.summary          = '限制屏幕旋转方位.'
  s.description      = <<-DESC
  限制屏幕旋转方位，需要在info.plist中设置包含此方位才可以..
                       DESC
  s.homepage         = 'https://github.com/KirstenDunst/LimitingDirection'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BrainCo' => 'cao_shixin@126.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

end
