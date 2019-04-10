Pod::Spec.new do |spec|
  spec.name         = 'WavesSDKCrypto'  
  spec.version      = '0.1'
  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true
  spec.license      = { :type => '' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'Mefilt'  
  spec.source_files =  'WavesSDKSource/Crypto/**/*.{swift}'
  spec.source       = { 'path' => 'WavesSDKSource/Crypto/**/*.{swift}' }

  # spec.source       = { 'git' => 'https://github.com/wavesplatform/WavesSDK-iOS.git' }

  spec.dependency 'RxSwift', '~> 4.0'
  
  spec.ios.framework = 'Foundation'
  spec.ios.framework = 'UIKit'
  spec.ios.framework = 'Security'  

  spec.dependency 'WavesSDKExtension'
  spec.dependency 'CryptoSwift'
  spec.dependency 'Curve25519'
  spec.dependency 'Base58'
  spec.dependency 'Keccak'
  spec.dependency 'Blake2'

end
