Pod::Spec.new do |spec|
  spec.name         = 'WavesSDK-iOS'
  spec.version      = '0.1'
  spec.license      = { :type => '' }
  spec.homepage     = ''
  spec.authors      = { 'Mefilt' => 'Mefilt' }
  spec.summary      = 'Mefilt'
  spec.source       = { 'path' => '' }
  spec.source_files = 'WavesSDK/Source/*.{swift}'


  spec.subspec 'Extensions' do |subSpec|
    subSpec.source_files =  'WavesSDK/Source/Extensions/*.{swift}'

    subSpec.dependency 'RxSwift'
    subSpec.dependency 'RxReachability'
    subSpec.dependency '25519'
    subSpec.dependency 'Base58'
    subSpec.dependency 'Keccak'
    subSpec.dependency 'Blake2'
    subSpec.dependency 'CryptoSwift'
    
  end

end
