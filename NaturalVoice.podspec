#
# Be sure to run `pod lib lint NaturalVoice.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NaturalVoice'
  s.version          = '0.1.0'
  s.summary          = 'Natural Voice'
  s.description      = ' This description is used to generate tags and improve search results. What does it do? Why did you write it? What is the focus? Try to keep it short, snappy and to the point. Write the description between the DESC delimiters below. Finally, do not worry about the indent, CocoaPods strips it!'
  s.homepage         = 'https://gitlab.com/lainara/natural-voice-mobile-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lay Channara' => 'lay.channara@gmail.com' }
  s.source           = { :git => 'https://gitlab.com/lainara/natural-voice-mobile-sdk-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'NaturalVoice/Classes/**/*'
  s.swift_version = '4.1'
  s.dependency 'Alamofire', '~> 4.7'
  
  # s.resource_bundles = {
  #   'NaturalVoice' => ['NaturalVoice/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
