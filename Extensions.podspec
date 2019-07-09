Pod::Spec.new do |spec|
  
  spec.name         = 'Extensions'
  spec.version      = '0.1'
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'Extensions'  

  spec.source_files =  'Extensions/**/**/*.{swift}'
  spec.source =  {  :git => ''}
  
  spec.ios.framework = 'Foundation'
  spec.ios.framework = 'UIKit'
  
  spec.static_framework = true
  
  # Assisstant
  spec.dependency 'RxSwift'
  spec.dependency 'RxSwiftExt'
  spec.dependency 'RxOptional'
  spec.dependency 'DeviceKit'
  
  # Waves
  spec.dependency 'WavesSDKExtensions'
  spec.dependency 'WavesSDK'
  spec.dependency 'WavesSDKCrypto'
end
