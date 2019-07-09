Pod::Spec.new do |spec|
  
  spec.name         = 'DataLayer'
  spec.version      = '0.1'
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'DataLayer'  

  spec.source_files =  'DataLayer/**/**/*.{swift}'
  spec.source =  {  :git => ''}
  
  spec.ios.framework = 'Foundation'
  
  spec.static_framework = true
  
  # External Service
  spec.dependency 'Firebase'

  spec.dependency 'Firebase/Core'
  spec.dependency 'Firebase/Database'
  spec.dependency 'Firebase/Auth'
  spec.dependency 'Firebase/InAppMessagingDisplay'

  spec.dependency 'Fabric'
  spec.dependency 'Crashlytics'
  spec.dependency 'Amplitude-iOS'
  spec.dependency 'AppsFlyerFramework'
  spec.dependency 'Sentry'

  # DB
  spec.dependency 'RealmSwift'
  spec.dependency 'RxRealm'
  spec.dependency 'Moya/RxSwift'
    

  # Assisstant
  spec.dependency 'RxSwift'
  spec.dependency 'RxSwiftExt'
  spec.dependency 'RxOptional'
  spec.dependency 'CSV.swift'
  
  # Waves
  spec.dependency 'WavesSDKExtensions'
  spec.dependency 'WavesSDK'
  spec.dependency 'WavesSDKCrypto'
  spec.dependency 'Extensions'
  spec.dependency 'DomainLayer'    
end
