#
# Be sure to run `pod lib lint RSStoreKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#

Pod::Spec.new do |s|
  s.name             = "RSMoneyMaker"
  s.version          = "0.0.3"
  s.summary          = "RSStoreKit provides an easy a way to implement IAPs"
  s.homepage         = "https://github.com/raostudios/RSStoreKit"
  s.license          = 'MIT'
  s.author           = { "Venkat S. Rao" => "vrao423@gmail.com" }
  s.source           = { :git => "https://github.com/raostudios/RSStoreKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/venkatrao'
  s.dependency       'RSInterfaceKit'
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'RSStoreKit' => ['Pod/Assets/*.png']
  }
  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'StoreKit'
end
