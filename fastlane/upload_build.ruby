def upload_testflight

  update_changelog
  
  PROJECT_IPA = "#{ENV['SCHEME_PROJECT']}-v#{ENV['VERSION']}-#{ENV['BUILD_NUMBER']}"
  PROJECT_IPA = "#{ENV['OUTPUT_PROJECT']}/#{PROJECT_IPA}.ipa"
  
  puts("#{ENV['APPLE_DEV_PORTAL_ID']}")
  puts("#{ENV['TESTFLIGHT_APP_IDENTITIFER']}")
  puts("#{ENV['APPSTORECONNECT_APP_APPLE_ID']}")
  puts("#{ENV['FASTLANE_ITC_TEAM_ID']}")
  puts("#{ENV['FASTLANE_TEAM_ID']}")
  puts("#{ENV['CHANGELOG']}")

  testflight(username: "#{ENV['APPLE_DEV_PORTAL_ID']}",
             app_identifier: "#{ENV['TESTFLIGHT_APP_IDENTITIFER']}",
             apple_id: "#{ENV['APPSTORECONNECT_APP_APPLE_ID']}",
             itc_provider: "#{ENV['FASTLANE_ITC_TEAM_ID']}",
             team_id: "#{ENV['FASTLANE_TEAM_ID']}",
             team_name: "#{ENV['FASTLANE_ITC_TEAM_NAME']}",
             dev_portal_team_id: "#{ENV['FASTLANE_TEAM_ID']}",
             wait_for_uploaded_build: "false",
             changelog: "#{ENV['CHANGELOG']}",
             ipa: PROJECT_IPA,
             skip_waiting_for_build_processing: true,
             skip_submission: true)
end

def upload_firebase
    
  rootNpm = sh("npm bin -g")

  puts("rootNPM #{rootNpm}")

  ENV['FIREBASEAPPDISTRO_FIREBASE_CLI_PATH'] =  "#{rootNpm}".strip + "/firebase"
  
  PROJECT_IPA = "#{ENV['SCHEME_PROJECT']}-v#{ENV['VERSION']}-#{ENV['BUILD_NUMBER']}"
  PROJECT_IPA = "#{ENV['OUTPUT_PROJECT']}/#{PROJECT_IPA}.ipa"
  
  update_changelog

  firebase_app_distribution(
    app: "#{ENV['FIREBASEAPPDISTRO_APP']}",
    ipa_path: "#{PROJECT_IPA}",
    groups: "QA.Team, Waves.Exchange.iOS",
    firebase_cli_path: "#{ENV['FIREBASEAPPDISTRO_FIREBASE_CLI_PATH']}",
    firebase_cli_token: "#{ENV['FIREBASEAPPDISTRO_FIREBASE_CLI_TOKEN']}",
    release_notes: ENV['CHANGELOG'])
end


lane :upload_crashlytics do

  update_changelog

  ENV['CRASHLYTICS_API_TOKEN']=sh("/usr/libexec/PlistBuddy -c 'Print :Fabric:APIKey' '#{Dir.pwd}/../WavesWallet-iOS/Resources/Fabric-Info.plist'")
  ENV['CRASHLYTICS_API_TOKEN']="#{ENV['CRASHLYTICS_API_TOKEN']}"
  ENV['CRASHLYTICS_BUILD_SECRET']=sh("/usr/libexec/PlistBuddy -c 'Print :Fabric:BuildSecret' '#{Dir.pwd}/../WavesWallet-iOS/Resources/Fabric-Info.plist'")
  ENV['CRASHLYTICS_BUILD_SECRET']="#{ENV['CRASHLYTICS_BUILD_SECRET']}"
  ROOT=File.expand_path("..", Dir.pwd)
  ENV['SUMBIT_PAPTH']="#{ROOT}/Pods/Crashlytics/submit"
  ENV['IPA_PATH']="#{GYM_OUTPUT_DIRECTORY}/#{GYM_OUTPUT_NAME}"
  
  puts "upload_crashlytics"
  sh("bash #{Dir.pwd}/run_fabric.sh")

  upload_symbols_to_crashlytics(gsp_path: "#{Dir.pwd}/../CommonResources/GoogleService-Info.plist")

end

lane :refresh_dsyms do
  
  PROJECT_DSYM = "#{ENV['SCHEME_PROJECT']}-v#{ENV['VERSION']}-#{ENV['BUILD_NUMBER']}"
  PROJECT_DSYM = "#{ENV['OUTPUT_PROJECT']}/#{PROJECT_DSYM}.app.dSYM.zip"

  sh("#{ROOT_PROJECT}/Pods/Fabric/upload-symbols -a #{FIREBASEAPP_FABRIC_TOKEN} -p ios #{PROJECT_DSYM}")
end

def update_changelog
        
  ENV['FL_BUILD_NUMBER_PROJECT'] = "#{ENV['ROOT_PROJECT']}/WavesWallet-iOS.xcodeproj"
  build_number = sh("/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' '#{Dir.pwd}/../WavesWallet-iOS/Info.plist'")
  version = ENV['VERSION'] 
  commit = last_git_commit
  branch = git_branch
  author = commit[:author] # author of the commit
  author_email = commit[:author_email] # email of the author of the commit
  hash = commit[:commit_hash] # long sha of commit
  short_hash = commit[:abbreviated_commit_hash] # short sha of commit

  # between: [ENV['CHANGELOG_BETWEEN_BRANCH'], hash],  # Optional, lets you specify a revision/tag range between which to collect commit info

  changelog = changelog_from_git_commits(      
    pretty: "- %ad %s \n",# Optional, lets you provide a custom format to apply to each commit when generating the changelog text
    date_format: "short",# Optional, lets you provide an additional date format to dates within the pretty-formatted string
    match_lightweight_tag: false,  # Optional, lets you ignore lightweight (non-annotated) tags when searching for the last tag
    merge_commit_filtering: "exclude_merges", # Optional, lets you filter out merge commits
    commits_count: 30
  )

  ENV['CHANGELOG']="Version: #{version} #{build_number}\nBranch: #{branch}\n#{changelog}"
  if ENV['CHANGELOG'].to_s.empty?
    ENV['CHANGELOG'] = "Not Found"
  end
end