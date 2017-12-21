#
# Be sure to run `pod lib lint AFFileDownLoader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AFFileDownLoader'
  s.version          = '0.2.0'
  s.summary          = 'AFFileDownLoader'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  对AFNetworking断点下载的简单封装 【下载】【暂停】【继续】【取消下载】【支持对下载状态实时监控】
  对NSURLSessionDataTask断点下载的简单封装 【下载】【暂停】【继续】【取消下载】【支持对下载状态实时监控】
                       DESC

  s.homepage         = 'https://github.com/shuaijianjian/AFFileDownLoader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZJ' => 'zhoujianjian@channelsoft.com' }
  s.source           = { :git => 'https://github.com/shuaijianjian/AFFileDownLoader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AFFileDownLoader/Classes/**/*'

  s.dependency 'AFNetworking', '~> 3.1'
  
  # s.resource_bundles = {
  #   'AFFileDownLoader' => ['AFFileDownLoader/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end
