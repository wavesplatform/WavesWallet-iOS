
def upload_testflight(ipa_path = create_ipa_path, changelog = create_changelog)
    
  testflight(username: "#{ENV['APPLE_DEV_PORTAL_ID']}",
             app_identifier: "#{ENV['TESTFLIGHT_APP_IDENTITIFER']}",
             apple_id: "#{ENV['APPSTORECONNECT_APP_APPLE_ID']}",
             itc_provider: "#{ENV['FASTLANE_ITC_TEAM_ID']}",
             team_id: "#{ENV['FASTLANE_TEAM_ID']}",
             team_name: "#{ENV['FASTLANE_ITC_TEAM_NAME']}",
             dev_portal_team_id: "#{ENV['FASTLANE_TEAM_ID']}",
             wait_for_uploaded_build: "false",
             changelog: changelog,
             ipa: ipa_path,
             skip_waiting_for_build_processing: true,
             skip_submission: true)
end

def upload_firebase(ipa_path = create_ipa_path, changelog = create_changelog)
    
  rootNpm = sh("npm bin -g")  
  firebase_cli_path = "#{rootNpm}".strip + "/firebase"
    
  firebase_app_distribution(
    app: "#{ENV['FIREBASEAPPDISTRO_APP']}",
    ipa_path: ipa_path,
    groups: "QA.Team, Waves.Exchange.iOS",
    firebase_cli_path: firebase_cli_path,
    firebase_cli_token: "#{ENV['FIREBASEAPPDISTRO_FIREBASE_CLI_TOKEN']}",
    release_notes: changelog)
end

def create_changelog
        
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

  changelog="Version: #{version} #{build_number}\nBranch: #{branch}\n#{changelog}"
  if changelog.to_s.empty?
    changelog = "Not Found"
  end
  return changelog
end

def create_ipa_path 

  project_ipa = "#{ENV['SCHEME_PROJECT']}-v#{ENV['VERSION']}-#{ENV['BUILD_NUMBER']}"
  project_ipa = "#{ENV['OUTPUT_PROJECT']}/#{project_ipa}.ipa"
  
  return project_ipa
end
