# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!(true)

# Enable the stricter search paths and module map generation for all pods
# use_modular_headers!

# Pods for MonkeyTest
target 'MonkeyTest' do
    pod 'SwiftMonkey'
end 

# Pods for WavesWallet-iOS
target 'WavesWallet-iOS' do

    inherit! :search_paths

    # UI
    pod 'RxCocoa'
    
    pod 'TTTAttributedLabel'    
    pod 'UITextView+Placeholder'

    pod 'SwipeView'
    pod 'MGSwipeTableCell'

    pod 'UPCarouselFlowLayout'
    pod 'InfiniteCollectionView', :git => 'https://github.com/wavesplatform/InfiniteCollectionView.git', :branch => 'swift5'
    pod 'RESideMenu', :git => 'https://github.com/wavesplatform/RESideMenu.git'

    pod 'Skeleton'
    pod 'Charts'
    pod 'Koloda'

    pod 'IQKeyboardManagerSwift'
    pod 'TPKeyboardAvoiding'
    
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
    pod 'Firebase/InAppMessagingDisplay'

    pod 'Amplitude-iOS'

    pod 'AppsFlyerFramework'

    # Helperrs
    pod 'IdentityImg', :git => 'https://github.com/wavesplatform/identity-img-swift.git'
    pod '25519', :git => 'https://github.com/wavesplatform/25519.git'
    pod 'Base58', :git => 'https://github.com/wavesplatform/Base58.git'
    pod 'Keccak', :git => 'https://github.com/wavesplatform/Keccak.git'
    pod 'Blake2', :git => 'https://github.com/wavesplatform/Blake2.git'
    pod 'CryptoSwift'
    pod 'KeychainAccess'
    pod 'QRCode'
    pod 'QRCodeReader.swift', '~> 9.0.1'
    pod 'SwiftDate'
    pod 'DeviceKit', '~> 1.3'
    
    # Cache & Download Images
    pod 'Kingfisher'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Network
    pod 'RxAlamofire'
    pod 'Moya/RxSwift'

    # Parser    
    pod 'CSV.swift'

    # Gen
    pod 'SwiftGen', '~> 5.3.0'

    # Debug
    pod 'Reveal-SDK', :configurations => ['Debug', 'Test']
    pod 'AppSpectorSDK', :configurations => ['Debug', 'Test']

    pod 'SwiftMonkeyPaws', :configurations => ['Debug']
    
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git'
    pod 'Fabric'
    pod 'Crashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            config.build_settings['SWIFT_VERSION'] = '4.2'
            
        end        
    end
end
