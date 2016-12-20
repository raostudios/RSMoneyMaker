#
# Be sure to run `pod lib lint RSMoneyMaker.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#

Pod::Spec.new do |s|

s.name             = "RSMoneyMaker"
s.version          = "0.0.10"
s.summary          = "RSMoneyMaker provides an easy a way to implement IAPs"
s.homepage         = "https://github.com/raostudios/RSMoneyMaker"
s.license          = 'MIT'
s.author           = { "Venkat S. Rao" => "vrao423@gmail.com" }
s.source           = { :git => "https://github.com/raostudios/RSMoneyMaker.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/venkatrao'
s.platform     = :ios, '8.0'
s.requires_arc = true


s.subspec 'RSMoneyMaker-Core' do |sdkit|
sdkit.source_files = 'Pod/Classes/Core/*.{h,m}'
sdkit.public_header_files = 'Pod/Classes/Core/*.h'
sdkit.dependency 'GCNetworkReachability'
end

s.subspec 'RSMoneyMaker-UI' do |sdkit|
sdkit.source_files = 'Pod/Classes/UI/*.{h,m}'
sdkit.public_header_files = 'Pod/Classes/UI/*.h'
sdkit.resources = 'Pod/Assets/*.png'
sdkit.dependency 'RSMoneyMaker/RSMoneyMaker-Core'
sdkit.dependency 'RSInterfaceKit'
end

end
