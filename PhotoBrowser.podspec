Pod::Spec.new do |s|
  s.name         = "PhotoBrowser"
  s.version      = "0.1"
  s.summary      = "PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer."

  s.homepage     = "https://github.com/cuzv/PhotoBrowser"
  s.license      = "MIT"
  s.author       = { "Moch Xiao" => "cuzval@gmail.com" }
  s.platform     = :ios, "7.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/cuzv/PhotoBrowser",
:tag => s.version.to_s }
  s.source_files = "PhotoBrowser/*.{h,m}"
  s.frameworks   = 'Foundation', 'UIKit'
end
