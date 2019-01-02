
Pod::Spec.new do |s|
  s.name         = "RNArenaMedia"
  s.version      = "1.0.0"
  s.summary      = "RNArenaMedia"
  s.description  = <<-DESC
                  RNArenaMedia
                   DESC
  s.homepage     = "https://www.baidu.com"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/DingLe888/react-native-arena-media.git", :tag => "master" }
  s.source_files  = "RNArenaMedia/**/*.{h,m}"
  s.requires_arc = true
  s.resource    =  "RNArenaMedia.bundle"

  s.dependency "React"
  #s.dependency "others"

end

  