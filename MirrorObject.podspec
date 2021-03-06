#
# Be sure to run `pod lib lint MirrorObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MirrorObject"
  s.version          = "1.1.0"
  s.summary          = "Mirroring dynamic properties automatically."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       Copy dynamic properties of objects that have same identifier.
                       DESC

  s.homepage         = "https://github.com/Matzo/MirrorObject"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Matzo" => "ksk.matsuo@gmail.com" }
  s.source           = { :git => "https://github.com/Matzo/MirrorObject.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.swift_version = '4.1'

  s.source_files = 'Pod/Classes/**/*'
end
