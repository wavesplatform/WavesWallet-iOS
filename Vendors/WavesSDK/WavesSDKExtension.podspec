Pod::Spec.new do |spec|
  spec.name         = 'WavesSDKExtension'  
  spec.version      = '0.1'
  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true
  spec.license      = { :type => '' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'Mefilt'  
  spec.source_files =  'WavesSDKSource/Extensions/**/*.{swift}'
  spec.source       = { 'path' => 'WavesSDKSource/Extensions/**/*.{swift}' }
  # spec.source =  { 
  #   :git => 'https://github.com/wavesplatform/WavesSDK-iOS.git',    
  #   :submodules => true
  # }

  # spec.source       = { 'git' => 'https://github.com/wavesplatform/WavesSDK-iOS.git' }
  spec.dependency 'RxSwift', '~> 4.0'
  
  spec.ios.framework = 'Foundation'
  spec.ios.framework = 'UIKit'
  # spec.ios.framework = 'Security'  

  # spec.dependency 'RxSwift', '~> 4.0'  
  # spec.dependency 'CryptoSwift'
  # spec.dependency 'Curve25519'
  # spec.dependency 'Base58'
  # spec.dependency 'Keccak'
  # spec.dependency 'Blake2'
  
  # spec.ios.framework = 'CoreTelephony'
  # spec.ios.framework = 'Foundation'
  # spec.ios.framework = 'UIKit'
  # spec.ios.framework = 'Security'  

end
