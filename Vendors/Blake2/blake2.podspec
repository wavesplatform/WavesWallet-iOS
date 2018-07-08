Pod::Spec.new do |spec|
  spec.name         = 'blake2'
  spec.version      = '0.1'
  spec.license      = { :type => '' }
  spec.homepage     = 'https://github.com/wavesplatform/WavesWallet-iOS/'
  spec.authors      = { '' => '' }
  spec.summary      = 'blake2'
  spec.source       = { 'path' => 'Source' }
  spec.source_files = 'Source/*.{h,c}'
  spec.public_header_files = 'Source/*.{h}'
  spec.preserve_path = 'module.modulemap'
  spec.module_map = 'module.modulemap'

end
