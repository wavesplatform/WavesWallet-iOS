  # Загружает все сертификаты и провижины для всех сборок и обновляет

  def all_app_force_update_certificates_and_provisions

    ENV['MATCH_APP_IDENTIFIERS'] = 
    [
      "com.wavesplatform.waveswallet.test",
      "com.wavesplatform.WavesWallet",
      "com.wavesplatform.waveswallet.dev",
      "com.wavesplatform.WavesWallet.widgetmarketpulse",
      "com.wavesplatform.waveswallet.dev.widgetmarketpulse",
      "com.wavesplatform.waveswallet.test.widgetmarketpulse"
    ]
    .join(",")
    
    ENV['MATCH_TYPE'] = "adhoc"
    force_update_certificates_and_provisions

    ENV['MATCH_TYPE'] = "appstore"
    force_update_certificates_and_provisions
          
    ENV['MATCH_TYPE'] = "development"
    force_update_certificates_and_provisions          
  end
  
  # Загружает сертификат и провижин для текущий сборки

  def download_certificates
      
    match(app_identifier: ENV['MATCH_APP_IDENTIFIERS'].split(","),
          git_url: "#{ENV['URL_CERTIFICATES_GIT']}",
          username: "#{ENV['APPLE_DEV_PORTAL_ID']}",
          type: "#{ENV['MATCH_TYPE']}",
          readonly: true,
          keychain_name: "#{ENV['MATCH_KEYCHAIN_NAME']}")
  end

  def force_update_certificates_and_provisions
    match(app_identifier: ENV['MATCH_APP_IDENTIFIERS'].split(","),
          git_url: ENV['URL_CERTIFICATES_GIT'],
          username: ENV['APPLE_DEV_PORTAL_ID'],
          type: ENV['MATCH_TYPE'],
          force: "true",
          force_for_new_devices: "true",
          keychain_name: ENV['MATCH_KEYCHAIN_NAME'],
          git_basic_authorization: ENV['MATCH_GIT_BASIC_AUTHORIZATION'])
  end
