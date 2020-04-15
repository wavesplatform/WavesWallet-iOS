Pod::Spec.new do |spec|
  
  spec.name         = 'WEProtobuf'
  spec.version      = '0.0.18'
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.swift_version = '5.0'

  spec.license      = { :type => 'MIT License', :file => 'LICENSE' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'mefilt@gmail.com' }
  spec.summary      = 'Extensions are helping for developer fast write code'  

  spec.source_files =  'Sources/**/*.{swift}'
  spec.source =  {  :git =>   'git@gitlab.wvservices.com:waves-exchange/mobile/weprotobuf-ios.git'}
  
  spec.ios.framework = 'Foundation'
  spec.ios.framework = 'UIKit'

  spec.dependency 'SwiftProtobuf'  

  spec.prepare_command = 
    <<-CMD        
        git submodule sync && git submodule update --init
        sh make.sh        
    CMD
end
