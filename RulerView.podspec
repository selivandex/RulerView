#
# Be sure to run `pod lib lint RulerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RulerView'
  s.version          = '0.1.3'
  s.summary          = 'Ruler control very similar to one which used in iOS Photos app'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Ruler control very similar to one which used in iOS Photos app.
                       DESC

  s.homepage         = 'https://github.com/selivandex/RulerView'
  s.screenshots     = 'https://siterio.s3-us-west-1.amazonaws.com/IMG_E4E05877A523-1.jpeg'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Selivanov' => 'selivandex@gmail.com' }
  s.source           = { :git => 'https://github.com/selivandex/RulerView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #   'RulerView' => ['RulerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
