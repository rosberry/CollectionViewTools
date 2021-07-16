#
# Be sure to run `pod lib lint CollectionViewTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CollectionViewTools'
  s.version          = '0.1.5'
  s.summary          = 'Powerful tool for making UICollectionView usage simple and comfortable.'
  s.swift_version    = ['5.0']

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Effective framework, similar to TableViewTools for making your UICollectionView usage simple and comfortable. It allows you to move UICollectionView configuration and interaction logic to separated objects and simply register, add and remove cells from the collection view.
               DESC

  s.homepage         = 'https://github.com/rosberry/CollectionViewTools'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitry Frishbuter' => 'dmitry.frishbuter@rosberry.com' }
  s.source           = { :git => 'https://github.com/rosberry/CollectionViewTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'Sources/**/*'

  s.dependency 'DeepDiff'

  # s.resource_bundles = {
  #   'CollectionViewTools' => ['Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
end
