Pod::Spec.new do |spec|
  spec.name         = 'WavesSDK'  
  spec.module_name = "Test"
  spec.version      = '0.2.5'
  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true
  spec.license      = { :type => '' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt@gmail.com' }
  spec.summary      = 'Mefilt'
  # spec.source       = { 'git' => 'https://github.com/wavesplatform/WavesSDK-iOS.git' }
  spec.source_files =  'WavesSDK/Source/Core/**/*.{swift}'
  spec.source       = { 'path' => 'WavesSDK/Source/Core/**/*.{swift}' }

#  spec.dependency 'CryptoSwift'

  # spec.swift_version = "4.2"

  # spec.ios.framework = 'CommonCrypto'
  # spec.ios.framework = 'Foundation'
  # spec.ios.framework = 'UIKit'
  # spec.ios.framework = 'Security'
  # spec.ios.framework = 'CommonCrypto'

  # subSpec.ios.framework = 'CoreTelephony'
  # subSpec.ios.framework = 'Foundation'
  # subSpec.ios.framework = 'UIKit'
  # subSpec.ios.framework = 'Security'
  # subSpec.ios.framework = 'CommonCrypto'

  # spec.vendored_frameworks = 'CommonCrypto'
  

  spec.subspec 'Extensions' do |subSpec|
    subSpec.source_files =  'WavesSDK/Source/Extensions/**/*.{swift}'
    
    subSpec.dependency 'RxSwift', '~> 4.0'
    subSpec.dependency 'RxReachability', '~> 0.1.8'    
    subSpec.dependency 'CryptoSwift'
    subSpec.dependency 'Curve25519'
    subSpec.dependency 'Base58'
    subSpec.dependency 'Keccak'
    subSpec.dependency 'Blake2'
    
    subSpec.ios.framework = 'CoreTelephony'
    subSpec.ios.framework = 'Foundation'
    subSpec.ios.framework = 'UIKit'
    subSpec.ios.framework = 'Security'  
  end

  spec.subspec 'Types' do |subSpec|
    subSpec.source_files =  'WavesSDK/Source/Types/**/*.{swift}'
    
    # subSpec.dependency 'RxSwift', '~> 4.0'
    # subSpec.dependency 'RxReachability', '~> 0.1.8'    
    # subSpec.dependency 'CryptoSwift'
    # subSpec.dependency 'Curve25519'
    # subSpec.dependency 'Base58'
    # subSpec.dependency 'Keccak'
    # subSpec.dependency 'Blake2'
    
    # subSpec.ios.framework = 'CoreTelephony'
    subSpec.ios.framework = 'Foundation'
    subSpec.ios.framework = 'UIKit'
    # subSpec.ios.framework = 'Security'  
  end

end
