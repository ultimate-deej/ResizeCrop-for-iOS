Pod::Spec.new do |s|
  s.name         = "ResizeCrop"
  s.version      = "1.0.0-RC"
  s.summary      = "A small but flexible library to resize and crop your images to fit within bounds"
  s.description  = <<-DESC
                    A small but flexible library to resize and crop your images to fit within bounds.
                    The intended usage is generating background images for different screen resolutions using a single asset.
                   DESC

  s.homepage     = "https://github.com/ultimate-deej/ResizeCrop-for-iOS"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Maxim Naumov" => "ultimate.deej@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ultimate-deej/ResizeCrop-for-iOS.git", :tag => "1.0.0-RC" }
  s.source_files  = "ResizeCrop/ResizeCrop.swift"
end
