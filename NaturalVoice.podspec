#
# Be sure to run `pod lib lint NaturalVoice.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'NaturalVoice'
    s.version          = '1.0.2'
    s.summary          = 'Public beta client library to integrate voice feedback using Natural Voice.'
    s.description      = 'Public beta client library to integrate voice feedback using Natural Voice (https://www.naturalvoice.ai) functions powered by Cloud Speech and Cloud Natural Language from Google Cloud Platform™ service'
    s.homepage         = 'https://github.com/aimmatic/natural-voice-mobile-sdk-ios'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Aimmatic Dev Team' => 'dev@aimmatic.com' }
    s.source           = { :git => 'https://github.com/aimmatic/natural-voice-mobile-sdk-ios.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.vendored_frameworks = 'NaturalVoice/Classes/Flac/FLACiOS.framework'
    s.source_files = 'NaturalVoice/Classes/*.{swift}', 'NaturalVoice/Classes/Flac/*.{c,m,h}', 'NaturalVoice/Classes/Flac/FLACiOS.framework/Headers/*.h'
    s.swift_version = '4.1'
    s.dependency 'Alamofire', '~> 4.7'
end
