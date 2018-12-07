# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!(true)

# Enable the stricter search paths and module map generation for all pods
# use_modular_headers!

# Pods for WavesWallet-iOS
target 'WavesWallet-iOS' do

    inherit! :search_paths

    # UI
    pod 'RxCocoa'
    pod 'RxDataSources'

    pod 'TTTAttributedLabel'    
    pod 'UITextView+Placeholder'

    pod 'SwipeView'
    pod 'MGSwipeTableCell'

    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'SVProgressHUD'

    pod 'UPCarouselFlowLayout'
    pod 'InfiniteCollectionView', :git => 'git@github.com:wavesplatform/InfiniteCollectionView.git'
    pod 'RESideMenu', :git => 'https://github.com/wavesplatform/RESideMenu.git'

    pod 'Skeleton'
    pod 'Charts', '~> 3.1.1'
    pod 'Koloda'

    pod 'IQKeyboardManagerSwift'
    pod 'TPKeyboardAvoiding'
    
    pod 'Device.swift', :git => 'https://github.com/schickling/Device.swift.git', :branch => 'swift-4.2'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'RxGesture'
    pod 'RxFeedback'
    pod 'RxReachability'

    # External Service
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'AppsFlyerFramework'

    pod 'Fabric'
    pod 'Crashlytics'

    # Helperrs
    pod 'IdentityImg', :git => 'git@github.com:wavesplatform/identity-img-swift.git'
    pod '25519', :git => 'git@github.com:wavesplatform/25519.git'
    pod 'base58', :path => 'Vendors/Base58'
    pod 'keccak', :path => 'Vendors/Keccak'
    pod 'blake2', :path => 'Vendors/Blake2'
    pod 'CryptoSwift'

    pod 'KeychainAccess'

    pod 'QRCode'
    pod 'QRCodeReader.swift'

    pod 'SwiftDate'

    # Cache
    pod 'Kingfisher'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Network
    pod 'RxAlamofire'
    pod 'Moya/RxSwift'

    # Parser
    pod 'SwiftyJSON'
    pod 'Gloss', '2.0.0-beta.1'
    pod 'CSV.swift'

    # Gen
    pod 'SwiftGen'

    # Debug
    pod 'Reveal-SDK', :configurations => ['Debug']
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            swift3_2pods = [
            'InfiniteCollectionView'
            ]

            if swift3_2pods.include? target.name
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end

            if config.name == 'Debug'
                # config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
                # config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
                # config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'

            end
        end
        
    end
end
