Pod::Spec.new do |spec|
  
  spec.name         = 'DomainLayer'
  spec.version      = '0.1'
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'DomainLayer'  

  spec.source_files =  'DomainLayer/**/**/*.{swift}'
  spec.source =  {  :git => ''}
  
  spec.ios.framework = 'Foundation'
  
  spec.static_framework = true
  
  # DB
  spec.dependency 'RealmSwift'
  spec.dependency 'RxRealm'

  # Assisstant
  spec.dependency 'RxSwift'
  spec.dependency 'RxSwiftExt'
  spec.dependency 'RxOptional'
  spec.dependency 'RxReachability'
  
  spec.dependency 'KeychainAccess'    
  
  spec.dependency 'CryptoSwift'    

  # Waves
  spec.dependency 'WavesSDKExtensions'
  spec.dependency 'WavesSDK'
  spec.dependency 'WavesSDKCrypto'
  spec.dependency 'Extensions'
end