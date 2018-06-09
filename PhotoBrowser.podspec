Pod::Spec.new do |s|
  s.name         = "PhotoBrowser"
  s.version      = "0.8.0"
  s.summary      = "PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer."

  s.homepage     = "https://github.com/cuzv/PhotoBrowser.git"
  s.license      = "MIT"
  s.author       = { "Roy Shaw" => "cuzval@gmail.com" }
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/cuzv/PhotoBrowser.git",
:tag => s.version.to_s }
  s.source_files = "Sources/*.{h,m}"
  s.frameworks   = 'Foundation', 'UIKit'
end
