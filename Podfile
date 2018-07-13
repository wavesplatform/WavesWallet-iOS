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
    pod 'UILabel+Copyable', '~> 1.0.0'
    pod 'UITextView+Placeholder'

    pod 'SwipeView'
    pod 'MGSwipeTableCell'

    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'SVProgressHUD'

    pod 'RDVTabBarController'
    pod 'UPCarouselFlowLayout'
    pod 'RESideMenu', :git => 'https://github.com/florianbuerger/RESideMenu.git'

    pod 'Charts'
    pod 'Koloda'

    # Assisstant
    pod 'RxSwift'
    pod 'RxGesture'

    pod 'IQKeyboardManagerSwift'
    pod 'TPKeyboardAvoiding'

    pod '25519', :git => 'git@github.com:wavesplatform/25519.git'    
    pod 'base58', :path => 'Vendors/Base58'
    pod 'keccak', :path => 'Vendors/Keccak'
    pod 'blake2', :path => 'Vendors/Blake2'

    pod 'KeychainAccess'
    
    pod 'QRCode'
    pod 'QRCodeReader.swift'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Network
    pod 'RxAlamofire'
    pod 'Moya/RxSwift'
  
    # Parser 
    pod 'SwiftyJSON'
    pod 'Gloss', '2.0.0-beta.1'    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
          config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
          config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
          
        end
      end
    end
  end