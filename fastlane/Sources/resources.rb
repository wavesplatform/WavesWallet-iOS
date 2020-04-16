# Загружает файлы из гита
def download_gitlab(url, path_to_save)   
    
  correct_url = "#{url}/raw?ref=master"    
  sh("rm -rf #{path_to_save}")
  sh("curl --request GET --header 'PRIVATE-TOKEN: #{ENV['AUTH_KEY_OPTIONS_PRIVATE_RESOURCES']}' #{correct_url} >> #{path_to_save}")
end

# Загружает файлы по урлу
def download_file(url, path_to_save)   
  
sh("rm -rf #{path_to_save}")
sh("curl --request GET #{url} >> #{path_to_save}")
end

# Загружаем ресурсы
def download_resources

  download_gitlab("#{ENV['URL_FABRIC_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/Fabric-Info.plist")

  download_gitlab("#{ENV['URL_FIREBASE_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/GoogleService-Info.plist")

  download_gitlab("#{ENV['URL_APPSFLYER_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/Appsflyer-Info.plist")

  download_gitlab("#{ENV['URL_APPSPECTOR_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/AppSpector-Info.plist")

  download_gitlab("#{ENV['URL_SENTRY_IO_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/Sentry-io-Info.plist")

  download_gitlab("#{ENV['URL_AMPLITUDE_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/Amplitude-Info.plist")
  
  download_gitlab("#{ENV['URL_FIREBASE_WAVESPLATFORM_PRIVATE_RESOURCES']}", "#{Dir.pwd}/../CommonResources/GoogleService-Info-Waves.plist")
  
  download_file("#{ENV['URL_ENVIROMENT_STAGENET_PROD']}", "#{Dir.pwd}/../CommonResources/environment_stagenet.json")
  download_file("#{ENV['URL_ENVIROMENT_MAINNET_PROD']}", "#{Dir.pwd}/../CommonResources/environment_mainnet.json")
  download_file("#{ENV['URL_ENVIROMENT_TESTNET_PROD']}", "#{Dir.pwd}/../CommonResources/environment_testnet.json")

  download_file("#{ENV['URL_ENVIROMENT_STAGENET_TEST']}", "#{Dir.pwd}/../CommonResources/environment_stagenet_test.json")
  download_file("#{ENV['URL_ENVIROMENT_MAINNET_TEST']}", "#{Dir.pwd}/../CommonResources/environment_mainnet_test.json")
  download_file("#{ENV['URL_ENVIROMENT_TESTNET_TEST']}", "#{Dir.pwd}/../CommonResources/environment_testnet_test.json")
  download_file("#{ENV['URL_FEE']}", "#{Dir.pwd}/../CommonResources/fee.json")
  download_file("#{ENV['URL_SPAM']}", "#{Dir.pwd}/../CommonResources/spam.csv")
  
end

# Загружаем файл с ключами и паролями :) 
def download_bundle_enviroments
  sh("rm -rf #{Dir.pwd}/../.env")
  sh("curl --request GET --header 'PRIVATE-TOKEN: #{ENV['AUTH_KEY_OPTIONS_PRIVATE_RESOURCES']}' #{ENV['URL_BUNDLE_ENV']} >> #{Dir.pwd}/../.env")
  sh("cat #{Dir.pwd}/../.env")
end
