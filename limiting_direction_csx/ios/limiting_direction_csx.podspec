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
  s.homepage         = 'https://github.com/KirstenDunst/FlutterPlugins/tree/main/limiting_direction_csx'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'csx' => 'cao_shixin@126.com' }
  # s.source           = { :path => '.' }
  s.source           = { :git => 'https://github.com/KirstenDunst/FlutterPlugins.git', :tag => s.version.to_s }
  s.source_files = 'limiting_direction_csx/Sources/limiting_direction_csx/**/*.swift'
  s.dependency 'Flutter'
  s.swift_version = '5.0'
  s.platform = :ios, '15.0'

end
