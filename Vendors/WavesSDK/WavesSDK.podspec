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
    subSpec.dependency 'RestKit/ObjectMapping'
    subSpec.dependency 'RestKit/Network'
    subSpec.dependency 'RestKit/CoreData'
  end

end
