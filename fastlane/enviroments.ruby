
# MARK Enviroment
#
# SCHEME_PROJECT - Scheme for build
# FASTLANE_APP_IDENTIFIER, TESTFLIGHT_APP_IDENTITIFER - App id for build and upload
# PROD_APP_IDENTIFIERS - Depricated
# APPSTORECONNECT_APP_APPLE_ID - APP Apple Id from itunes connect. The id need where is uploading to Testfligt
# URL_ROOT_CONFIG_PRIVATE_RESOURCES - The var from .env file
# URL_FIREBASE_PRIVATE_RESOURCES -  Private API Key for Firebase Waves Exchange
# URL_FIREBASE_WAVESPLATFORM_PRIVATE_RESOURCES - Private API Key for Firebase Waves Platform
# URL_APPSFLYER_PRIVATE_RESOURCES - Private API Key for Appflyer
# URL_AMPLITUDE_PRIVATE_RESOURCES - Private API Key for Amplitude
# URL_APPSPECTOR_PRIVATE_RESOURCES - Private API Key for AppSpector
# URL_SENTRY_IO_PRIVATE_RESOURCES - Private API Key for Sentry
# URL_FABRIC_PRIVATE_RESOURCES - Private API Key for Fabric
# EXPORT_OPTIONS - It file need for build project (RTFM)
# MATCH_TYPE - One from few type build
# CHANGELOG_BETWEEN_BRANCH - We create changelog contain last commit between current and the var

def dev_enviroment
    
    ENV['SCHEME_PROJECT'] ="WavesWallet-Dev"
    ENV['FASTLANE_APP_IDENTIFIER'] = "com.wavesplatform.waveswallet.dev"
    ENV['TESTFLIGHT_APP_IDENTITIFER'] = "com.wavesplatform.waveswallet.dev"
    ENV['MATCH_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet.dev,com.wavesplatform.waveswallet.dev.widgetmarketpulse"
    ENV['PROD_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet"

    ENV['APPSTORECONNECT_APP_APPLE_ID'] = ""

    ENV['URL_FIREBASE_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Test.plist"
    ENV['URL_FIREBASE_WAVESPLATFORM_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Test-Waves.plist"
    ENV['URL_APPSFLYER_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Appsflyer-Info-Dev.plist"
    ENV['URL_AMPLITUDE_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Amplitude-Info-Test.plist"
    ENV['URL_APPSPECTOR_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/AppSpector-Info.plist"
    ENV['URL_SENTRY_IO_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Sentry-io-Info.plist"
    ENV['URL_FABRIC_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Fabric-Info.plist"
  
    ENV['EXPORT_OPTIONS'] = "#{Dir.pwd}/ExportOptions-AdHoc.plist"

    ENV['MATCH_TYPE'] = "adhoc"
    ENV['CHANGELOG_BETWEEN_BRANCH']="develop"
  end

  def general_prod_enviroment
    
    ENV['FASTLANE_APP_IDENTIFIER'] = "com.wavesplatform.WavesWallet"
    ENV['TESTFLIGHT_APP_IDENTITIFER'] = "com.wavesplatform.WavesWallet"
    ENV['MATCH_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet,com.wavesplatform.WavesWallet.widgetmarketpulse"
    ENV['PROD_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet"

    ENV['APPSTORECONNECT_APP_APPLE_ID'] = "1233158971"

    ENV['URL_FIREBASE_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Prod.plist"
    ENV['URL_FIREBASE_WAVESPLATFORM_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Prod-Waves.plist"
    ENV['URL_APPSFLYER_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Appsflyer-Info-Prod.plist"
    ENV['URL_AMPLITUDE_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Amplitude-Info-Prod.plist"
    ENV['URL_APPSPECTOR_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/AppSpector-Info.plist"
    ENV['URL_SENTRY_IO_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Sentry-io-Info.plist"
    ENV['URL_FABRIC_PRIVATE_RESOURCES'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Fabric-Info.plist"
    
    ENV['CHANGELOG_BETWEEN_BRANCH']="master"
    ENV['FIREBASEAPPDISTRO_APP'] = "1:233086447937:ios:41c150c39c0482255231c0"
  end

  def prod_enviroment
    
    general_prod_enviroment

    ENV['EXPORT_OPTIONS'] = "#{Dir.pwd}/ExportOptions-AppStore.plist"
    ENV['MATCH_TYPE'] = "appstore"    
    ENV['SCHEME_PROJECT'] ="WavesWallet-Release"
    
  end

  def prod_adhoc_enviroment
    
    general_prod_enviroment    
    ENV['EXPORT_OPTIONS'] = "#{Dir.pwd}/ExportOptions-AdHoc.plist"
    ENV['MATCH_TYPE'] = "adhoc"
    ENV['SCHEME_PROJECT'] ="WavesWallet-Release-Adhoc"    
  end

  def test_enviroment

    ENV['SCHEME_PROJECT'] ="WavesWallet-Test"
    ENV['FASTLANE_APP_IDENTIFIER'] = "com.wavesplatform.waveswallet.test"
    ENV['TESTFLIGHT_APP_IDENTITIFER'] = "com.wavesplatform.waveswallet.test"
    ENV['MATCH_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet.test,com.wavesplatform.waveswallet.test.widgetmarketpulse"    
    ENV['PROD_APP_IDENTIFIERS'] = "com.wavesplatform.waveswallet"

    ENV['APPSTORECONNECT_APP_APPLE_ID'] = "1438015790"

    ENV['URL_FIREBASE'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Test.plist"
    ENV['URL_FIREBASE_WAVESPLATFORM'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/GoogleService-Info-Test-Waves.plist"
    
    ENV['URL_APPSFLYER'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Appsflyer-Info-Prod.plist"
    ENV['URL_AMPLITUDE'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Amplitude-Info-Prod.plist"
    ENV['URL_APPSPECTOR'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/AppSpector-Info.plist"
    ENV['URL_SENTRY_IO'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Sentry-io-Info.plist"
    ENV['URL_FABRIC'] = "#{ENV['URL_ROOT_CONFIG_PRIVATE_RESOURCES']}/Fabric-Info.plist"

    ENV['EXPORT_OPTIONS'] = "#{Dir.pwd}/ExportOptions-AppStore.plist"

    ENV['MATCH_TYPE'] = "appstore"
    ENV['CHANGELOG_BETWEEN_BRANCH']="master"    
  end