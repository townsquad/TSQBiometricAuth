#
# Be sure to run `pod lib lint TSQBiometricAuth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TSQBiometricAuth'
    s.version          = '1.0.3'
    s.summary          = 'A lib for biometric authentication.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    TSQBiometricAuth is a lib to enable the use of biometric authentication via simple ViewController usage.
    DESC
    
    s.homepage         = 'https://bitbucket.org/socialcondo/ios-biometric-authentication/src/master/'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Kévin Cardoso de Sá' => 'kevin@townsq.com.br' }
    s.source           = { :git => 'https://bitbucket.org/socialcondo/ios-biometric-authentication.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '9.0'
    s.swift_version = '4.1'
    
    s.source_files = 'TSQBiometricAuth/Classes/**/*.{swift}'
    
    # s.resource_bundles = {
    #   'TSQBiometricAuth' => ['TSQBiometricAuth/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'RxSwift', '~> 4.0'
    s.dependency 'RxCocoa', '~> 4.0'
end
