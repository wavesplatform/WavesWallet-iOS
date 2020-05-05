# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks! :linkage => :dynamic

install! 'cocoapods', :disable_input_output_paths => true

# install! 'cocoapods', :generate_multiple_pod_projects => true

workspace 'WavesWallet-iOS'
# project 'StandartTools/StandartTools'
project 'WavesWallet-iOS'

# 
# 

def firebase_dependencies
    pod 'Firebase'
    pod 'Firebase/Analytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/InAppMessagingDisplay'
    pod 'Firebase/Messaging'
end

# 
# 

# target 'StandartTools' do
#     workspace 'WavesWallet-iOS.xcworkspace'
#     project 'StandartTools/StandartTools.xcodeproj'
#     # данный таргет не должен содержать никаких зависимостей.
# end

# project 'AppTools/AppTools.xcodeproj' do 
#     target 'AppTools' do
#         inherit! :search_paths
#         workspace 'WavesWallet-iOS'
#         project 'AppTools/AppTools'

#         use_frameworks! :linkage => :dynamic

#         pod 'RxCocoa'
#         pod 'RxSwift'
#     end
# end

# target 'WavesUIKit' do
#     workspace 'WavesWallet-iOS'
#     project 'WavesUIKit/WavesUIKit'

#     pod 'RxCocoa'
#     pod 'RxSwift'
# end

target 'WavesWallet-iOS' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    use_frameworks! :linkage => :dynamic

    pod 'Charts'
    pod 'Down'
    pod 'IdentityImg', :git => 'https://github.com/wavesplatform/identity-img-swift.git'
    pod 'InfiniteCollectionView', :git => 'https://github.com/wavesplatform/InfiniteCollectionView.git', :branch => 'swift5'
    pod 'Intercom'
    pod 'IQKeyboardManagerSwift'
    pod 'Kingfisher'
    pod 'MGSwipeTableCell'
    pod 'QRCode'
    pod 'QRCodeReader.swift', '~> 9.0.1'
    pod 'RESideMenu', :git => 'https://github.com/wavesplatform/RESideMenu.git'
    pod 'Reveal-SDK', '~> 20', :configurations => ['dev-debug', 'dev-adhoc', 'test-dev', 'release-dev']
    pod 'RxCocoa'
    pod 'RxFeedback'
    pod 'RxSwift'
    pod 'Skeleton'
    pod 'SwiftGen', '~> 5.3.0'
    pod 'SwiftLint'
    pod 'SwiftMonkeyPaws', :configurations => ['dev-debug', 'dev-adhoc']
    # pod 'TPKeyboardAvoiding'
    pod 'TTTAttributedLabel'
    pod 'UPCarouselFlowLayout'
end

target 'DomainLayer' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    pod 'CryptoSwift'
    pod 'KeychainAccess'
    pod 'RealmSwift'
    pod 'RxCocoa'
    pod 'RxReachability'
    pod 'RxRealm'
    pod 'RxSwift'
end

target 'DataLayer' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    firebase_dependencies

    pod 'RxRealm'
    pod 'RxCocoa'
    pod 'RxSwift'
    pod 'Sentry'
    pod 'Amplitude-iOS'
    pod 'Crashlytics'
    pod 'CryptoSwift'
    pod 'CSV.swift'
    pod 'DeviceKit'
    pod 'Fabric'
    pod 'KeychainAccess'
    pod 'Moya'
    pod 'Moya/RxSwift'    

    # pod 'SwiftGRPC'
    pod 'gRPC-Swift', '1.0.0-alpha.11'
    # pod 'SwiftProtobuf'
    # pod 'WEProtobuf', :git => 'git@gitlab.wvservices.com:waves-exchange/mobile/weprotobuf-ios.git'
end

target 'Extensions' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    pod 'DeviceKit'
    pod 'Kingfisher'
    pod 'RxCocoa'
    pod 'RxFeedback'
    pod 'RxReachability'
    pod 'RxSwift'
end

target 'MarketPulseWidget' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    pod 'Amplitude-iOS'
    pod 'Kingfisher'
    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RealmSwift'
    pod 'RxCocoa'
    pod 'RxFeedback'
    pod 'RxRealm'
    pod 'RxSwift'
end

#
#


target 'DomainLayerTests' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'
end

target 'DataLayerTests' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'
end

target 'MonkeyTest' do
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'
    pod 'SwiftMonkey'
end

target 'DummyForTest' do 
    workspace 'WavesWallet-iOS'
    project 'WavesWallet-iOS'

    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
end

#
#

target 'WavesSDK' do
    project 'Vendors/WavesSDK/WavesSDK'

    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
end

target 'WavesSDKExtensions' do
    project 'Vendors/WavesSDK/WavesSDK'

    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
end

target 'WavesSDKCrypto' do
    project 'Vendors/WavesSDK/WavesSDK'

    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
end

target 'StubTest' do 
    project 'Vendors/WavesSDK/WavesSDK'

    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
end

target 'WavesSDKTests' do
    project 'Vendors/WavesSDK/WavesSDK'

    pod 'Fakery'
    pod 'Nimble'
    pod 'RxSwift'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            if ['QRCode'].include? target.name
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
            
        end        
    end 

    remove_static_framework_duplicate_linkage({
        'DataLayer' => [
            'Fabric', 
            'Crashlytics',
            'AppsFlyerFramework',
            'Amplitude-iOS',
            'Amplitude_iOS',
            'FirebaseCore',
            'FirebaseDatabase',
            'FirebaseAuth',
            'FIRAnalyticsConnector',
            'FirebaseAnalytics',
            'FirebaseCoreDiagnostics',
            'FirebaseInstanceID',
            'FirebaseInAppMessaging',
            'GoogleAppMeasurement',
            'GTMSessionFetcher',
            'GoogleUtilities'
        ]
    })

end

## This code take from https://github.com/CocoaPods/CocoaPods/issues/7155#issuecomment-461395735
PROJECT_ROOT_DIR = File.dirname(File.expand_path(__FILE__))
PODS_DIR = File.join(PROJECT_ROOT_DIR, 'Pods')
PODS_TARGET_SUPPORT_FILES_DIR = File.join(PODS_DIR, 'Target Support Files')

# CocoaPods provides the abstract_target mechanism for sharing dependencies between distinct targets.
# However, due to the complexity of our project and use of shared frameworks, we cannot simply bundle everything under
# a single abstract_target. Using a pod in a shared framework target and an app target will cause CocoaPods to generate
# a build configuration that links the pod's frameworks with both targets. This is not an issue with dynamic frameworks,
# as the linker is smart enough to avoid duplicate linkage at runtime. Yet for static frameworks the linkage happens at
# build time, thus when the shared framework target and app target are combined to form an executable, the static
# framework will reside within multiple distinct address spaces. The end result is duplicated symbols, and global
# variables that are confined to each target's address space, i.e not truly global within the app's address space.
#
# Previously we avoided this by linking the static framework with a single target using an abstract_target, and then
# provided a shim to expose their interfaces to other targets. The new approach implemented here removes the need for
# shim by modifying the build configuration generated by CocoaPods to restrict linkage to a single target.
def remove_static_framework_duplicate_linkage(static_framework_pods)
  puts "Removing duplicate linkage of static frameworks"

  Dir.glob(File.join(PODS_TARGET_SUPPORT_FILES_DIR, "Pods-*")).each do |path|
    pod_target = path.split('-', -1).last

    static_framework_pods.each do |target, pods|
      next if pod_target == target
      frameworks = pods.map { |pod| identify_frameworks(pod) }.flatten

      Dir.glob(File.join(path, "*.xcconfig")).each do |xcconfig|
        lines = File.readlines(xcconfig)

        if other_ldflags_index = lines.find_index { |l| l.start_with?('OTHER_LDFLAGS') }
          other_ldflags = lines[other_ldflags_index]

          frameworks.each do |framework|
            other_ldflags.gsub!("-framework \"#{framework}\"", '')
          end

          File.open(xcconfig, 'w') do |fd|
            fd.write(lines.join)
          end
        end
      end
    end
  end
end

def identify_frameworks(pod)
  frameworks = Dir.glob(File.join(PODS_DIR, pod, "**/*.framework")).map { |path| File.basename(path) }

  if frameworks.any?
    return frameworks.map { |f| f.split('.framework').first }
  end

  return pod
end
