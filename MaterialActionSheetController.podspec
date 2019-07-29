#
# Be sure to run `pod lib lint MaterialActionSheetController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MaterialActionSheetController'
  s.version          = '2.0'
  s.summary          = 'A Google like action sheet for iOS written in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Lightweight and totally customizable. Create and present it the way you do with UIAlertController.
                       DESC

  s.homepage         = 'https://github.com/ntnhon/MaterialActionSheetController'
  s.screenshots     = 'https://raw.githubusercontent.com/ntnhon/MaterialActionSheetController/6f438d03c118c8e19bac792bdeef9383f0991e67/Screenshots/Full_option_light.png', 'https://raw.githubusercontent.com/ntnhon/MaterialActionSheetController/6f438d03c118c8e19bac792bdeef9383f0991e67/Screenshots/Full_option_dark.png', 'https://raw.githubusercontent.com/ntnhon/MaterialActionSheetController/6f438d03c118c8e19bac792bdeef9383f0991e67/Screenshots/Custom_header_light.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Thanh-Nhon Nguyen' => 'ntnhon.cs@gmail.com' }
  s.source           = { :git => 'https://github.com/ntnhon/MaterialActionSheetController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'MaterialActionSheetController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MaterialActionSheetController' => ['MaterialActionSheetController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
