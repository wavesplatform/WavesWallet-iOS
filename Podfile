
# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

install! 'cocoapods', :disable_input_output_paths => true

use_frameworks!(true)

# Enable the stricter search paths and module map generation for all pods
# use_modular_headers!

# Pods for MonkeyTest
target 'MonkeyTest' do
    pod 'SwiftMonkey'
end 


def wavesSDKPod
    # pod 'WavesSDKExtensions', :git => 'https://github.com/wavesplatform/WavesSDK-iOS'
    # pod 'WavesSDK', :git => 'https://github.com/wavesplatform/WavesSDK-iOS'
    # pod 'WavesSDKCrypto', :git => 'https://github.com/wavesplatform/WavesSDK-iOS'
end

# load './Vendors/WavesSDK/Podfile'
    
workspace 'WavesWallet-iOS.xcworkspace'
project 'Vendors/WavesSDK/WavesSDK.xcodeproj'
project 'WavesWallet-iOS.xcodeproj'


abstract_target 'example' do
    
end

# Pods for WavesWallet-iOS
target 'WavesWallet-iOS' do

    project 'WavesWallet-iOS.xcodeproj'    

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

    pod 'IdentityImg', :git => 'https://github.com/wavesplatform/identity-img-swift.git'
    pod 'QRCode'
    pod 'QRCodeReader.swift', '~> 9.0.1'    
    pod 'SwiftDate'
    pod 'Kingfisher'

    # Waves
    wavesSDKPod

    # Waves Internal
    # pod 'DomainLayer', :path => '.'
    # pod 'DataLayer', :path => '.'
    # pod 'Extensions', :path => '.'
 
    # Code Gen
    pod 'SwiftGen', '~> 5.3.0'

    # Debug
    # pod 'Reveal-SDK', :configurations => ['Debug']
    pod 'AppSpectorSDK', :configurations => ['dev-debug', 'dev-adhoc', 'test-dev']
    pod 'SwiftMonkeyPaws', :configurations => ['dev-debug', 'dev-adhoc']
        
    # pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git'

end

target 'DomainLayer' do
    project 'WavesWallet-iOS.xcodeproj'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'        
    pod 'RxReachability'

    pod 'KeychainAccess'        

    # Waves    
    wavesSDKPod
    # pod 'Extensions', :path => '.'
    
    pod 'CryptoSwift'
end

target 'Extensions' do
    project 'WavesWallet-iOS.xcodeproj'    

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'DeviceKit'

    # Waves
    wavesSDKPod
end


target 'DataLayer' do
    project 'WavesWallet-iOS.xcodeproj'
    
    # External Service
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/InAppMessagingDisplay'

    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Amplitude-iOS'
    pod 'AppsFlyerFramework'
    pod 'Sentry'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'CSV.swift'

    pod 'CryptoSwift'
    pod 'DeviceKit'
    pod 'KeychainAccess'

    pod 'RxSwift'
    pod 'Moya'
    pod 'Moya/RxSwift'
end

target 'DomainLayerTests' do
    project 'WavesWallet-iOS.xcodeproj'
    inherit! :search_paths         
end

target 'DataLayerTests' do
    project 'WavesWallet-iOS.xcodeproj'    
end

target 'WavesSDK' do    
    project 'Vendors/WavesSDK/WavesSDK.xcodeproj'
    pod 'RxSwift'
    pod 'Moya'
    pod 'Moya/RxSwift'
end

target 'WavesSDKExtensions' do    
    project 'Vendors/WavesSDK/WavesSDK.xcodeproj'
    pod 'RxSwift'
    pod 'Moya'
    pod 'Moya/RxSwift'
end

target 'WavesSDKCrypto' do    
    project 'Vendors/WavesSDK/WavesSDK.xcodeproj'
    pod 'RxSwift'
    pod 'Moya'
    pod 'Moya/RxSwift'
end

post_install do |installer|

    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            config.build_settings['SWIFT_VERSION'] = '4.2'
            
        end        
    end
end
