Pod::Spec.new do |spec|

  spec.name         = "StandartTools"
  spec.version      = "0.0.1"
  spec.requires_arc = true
  spec.summary      = "Набор максимально переиспользуемых инструментов"
  spec.description  = "Данная зависимость не содержит в себе сторонних библиотек"
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://wavesplatform.com'

  spec.author             = { "Vladimir Vysotsky" => "wwwvova1997@gmail.com" }
  spec.ios.deployment_target = '11.0'

  spec.source       = { :git => "" }

  spec.source_files  = "StandartTools/**/*.{swift}"

  spec.public_header_files = "StandartTools.h"
end
