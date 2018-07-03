Pod::Spec.new do |spec|
  spec.name         = 'base58'
  spec.version      = '0.1'
  spec.license      = { :type => 'MIT license' }
  spec.homepage     = 'https://github.com/wavesplatform/WavesWallet-iOS/'
  spec.authors      = { '' => '' }
  spec.summary      = 'base58'
  spec.source       = { 'path' => 'Source' }
  spec.source_files = 'Source/*.{h,c}'
  spec.preserve_path = 'module.modulemap'
  spec.module_map = 'module.modulemap'

end
