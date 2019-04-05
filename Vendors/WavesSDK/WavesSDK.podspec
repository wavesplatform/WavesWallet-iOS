Pod::Spec.new do |spec|
  spec.name         = 'WavesSDK'
  spec.version      = '0.1'
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.license      = { :type => '' }
  spec.homepage     = 'https://wavesplatform.com'
  spec.authors      = { 'Mefilt' => 'Mefilt' }
  spec.summary      = 'Mefilt'
  # spec.source       = { 'git' => 'https://github.com/wavesplatform/WavesSDK-iOS.git' }
  spec.source_files = ''
  spec.source       = { 'path' => 'WavesSDK' }
  spec.swift_version = "4.2"

  spec.ios.framework = 'CoreTelephony'
  # spec.ios.framework = 'Foundation'
  # spec.ios.framework = 'UIKit'
  # spec.ios.framework = 'Security'
  # spec.ios.framework = 'CommonCrypto'

  # subSpec.ios.framework = 'CoreTelephony'
  # subSpec.ios.framework = 'Foundation'
  # subSpec.ios.framework = 'UIKit'
  # subSpec.ios.framework = 'Security'
  # subSpec.ios.framework = 'CommonCrypto'

  spec.vendored_frameworks = 'CommonCrypto'
  

  spec.subspec 'Extensions' do |subSpec|
    subSpec.source_files =  'WavesSDK/Source/Extensions/**/*.{swift}'

    subSpec.dependency 'RxSwift', '~> 4.0'
    subSpec.dependency 'RxReachability', '~> 0.1.8'    
    subSpec.dependency 'CryptoSwift', '~> 0.15'    
    subSpec.dependency 'Curve25519'
    subSpec.dependency 'Base58'
    subSpec.dependency 'Keccak'
    subSpec.dependency 'Blake2'
    
    # subSpec.ios.framework = 'CoreTelephony'
    # subSpec.ios.framework = 'Foundation'
    # subSpec.ios.framework = 'UIKit'
    # subSpec.ios.framework = 'Security'
    subSpec.ios.framework = 'CommonCrypto'
  end

end
