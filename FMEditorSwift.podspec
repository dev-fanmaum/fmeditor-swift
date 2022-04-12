#
# Be sure to run `pod lib lint FMEditorSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FMEditorSwift'
  s.version          = '1.1.1'
  s.summary          = 'HTML Editor for iOS written in Swift'
  s.homepage         = 'https://github.com/dev-fanmaum/fmeditor-swift'
  s.license          = { :type => 'BSD 3-clause', :file => 'LICENSE' }
  s.author           = { 'Fanmaum Inc.' => 'dev@fanmaum.com' }
  s.source           = { :git => 'https://github.com/dev-fanmaum/fmeditor-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/fanplus_app'
  s.swift_version    = '5.0'
  s.ios.deployment_target = '12.1'
  s.source_files = 'FMEditorSwift/Classes/*'
  
  
  s.resource_bundles = {
     'FMEditorSwift' => [
        'FMEditorSwift/Assets/icons/*',
        'FMEditorSwift/Assets/editor/*'
     ]
  }
  s.frameworks = 'UIKit', 'WebKit'

end
