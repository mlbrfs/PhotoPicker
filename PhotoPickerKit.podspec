Pod::Spec.new do |s|

  s.name         = "PhotoPickerKit"
  s.version      = "0.5.0"
  s.summary      = "Image selector"

  s.description  = <<-DESC
		   Image selector with swift (iPhone and iPad) for swift4.2
                   DESC

  s.homepage     = "https://github.com/121372288/PhotoPicker"

  s.license      = "MIT"

  s.author             = { "121372288" => "121372288@qq.com" }

  s.platform     = :ios, "8.0"

  # s.ios.deployment_target = "10.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/121372288/PhotoPicker.git", :tag => s.version }

  s.swift_version = "5.0"

  s.source_files  = ["PhotoPicker/**/*.swift", "PhotoPicker/*.swift", "PhotoPicker/PhotoPicker.h"]
  s.public_header_files = ["PhotoPicker/PhotoPicker.h"]
  # s.exclude_files = "PhotoPicker/Info.plist"
  s.resource     = 'PhotoPicker/PhotoPicker.bundle'

  s.frameworks  = "UIKit", "Foundation", "Photos", "AVFoundation", "AVKit"

  s.requires_arc = true

end
