source 'https://github.com/wavesplatform/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!(true)

# Pods for WavesSDK
target 'WavesSDK' do

    inherit! :search_paths

    pod 'RxSwift'
    pod 'RxReachability'
    pod 'Curve25519'
    pod 'Base58'
    pod 'Keccak'
    pod 'Blake2'
    pod 'CryptoSwift'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
            config.build_settings['SWIFT_VERSION'] = '4.2'
            
        end        
    end
end
