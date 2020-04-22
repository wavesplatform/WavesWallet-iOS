Pod::Spec.new do |spec|
  spec.name         = "AppTools"
  spec.version      = "0.0.1"
  spec.summary      = "Содержит в себе расширения необходимые для конкретно нашего приложения"
  spec.description  = "Содержит в себе расширения необходимые для конкретно нашего приложения (например для построения модулей, rx extensions, foundation class extensions и тд)"

  spec.homepage     = "https://wavesplatform.com"
  spec.license      = { :type => "MIT" }
  spec.author             = { "Vladimir Vysotsky" => "wwwvova1997@gmail.com" }
  spec.ios.deployment_target = "11.0"
  spec.source       = { :git => "" }

  spec.source_files  = "AppTools/**/*.{swift}"

  spec.public_header_files = "AppTools.h"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  spec.ios.framework  = "Foundation"

  spec.dependency "StandartTools"
  spec.dependency "RxCocoa"
  spec.dependency "RxSwift"

end
