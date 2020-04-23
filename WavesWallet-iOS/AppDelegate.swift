//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Exchange. All rights reserved.
//

import IQKeyboardManagerSwift
import RESideMenu
import RxSwift
import UIKit

import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

import DataLayer
import DomainLayer
import Extensions
import Firebase
import FirebaseMessaging
import Intercom


#if DEBUG
import SwiftMonkeyPaws
#endif

#if DEBUG
enum UITest {
    static var isEnabledonkeyTest: Bool { CommandLine.arguments.contains("--MONKEY_TEST") }
}
#endif

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var disposeBag = DisposeBag()
    
    var window: UIWindow?
    
    var appCoordinator: AppCoordinator!
    
    lazy var migrationInteractor: MigrationUseCaseProtocol = UseCasesFactory.instance.migration
    
    #if DEBUG
    var paws: MonkeyPaws?
    #endif
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var url: URL?
        
        if let path = launchOptions?[.url] as? String {
            url = URL(string: path)
        }
        
        if let scheme = url?.scheme, DeepLink.scheme != scheme {
            return false
        }
        
        var deepLink: DeepLink?
        
        if let url = url {
            deepLink = DeepLink(url: url)
        }
                
        guard setupLayers() else { return false }
        
        setupUI()
        setupServices()
        
        let router = WindowRouter.windowFactory(window: window!)
        
        appCoordinator = AppCoordinator(router, deepLink: deepLink)
        
        migrationInteractor
            .migration()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in },
                       onError: { _ in },
                       onCompleted: { self.appCoordinator.start() })
            .disposed(by: disposeBag)
        
        application.registerForRemoteNotifications()
                
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if DeepLink.scheme != url.scheme {
            return false
        }
        
        appCoordinator.openURL(link: DeepLink(url: url))
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoordinator.applicationDidEnterBackground()
        
        Intercom.hideMessenger()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appCoordinator.applicationDidBecomeActive()
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool { false }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Intercom.setDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        appCoordinator.application(application,
                                   didReceiveRemoteNotification: userInfo,
                                   fetchCompletionHandler: completionHandler)
    }
}

extension AppDelegate {
    func setupUI() {
        Swizzle(initializers: [UIView.passtroughInit, UIView.insetsInit, UIView.shadowInit]).start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .basic50
        
        #if DEBUG
        if UITest.isEnabledonkeyTest {
            paws = MonkeyPaws(view: window!)
        }
        #endif
        
        IQKeyboardManager.shared.enable = true
        UIBarButtonItem.appearance().tintColor = UIColor.black
        
        Language.load(localizable: Localizable.self, languages: Language.list)
    }
    
    func setupLayers() -> Bool {
        guard let googleServiceInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }
        
        guard let googleServiceInfoPathWaves = Bundle.main.path(forResource: "GoogleService-Info-Waves", ofType: "plist") else {
            return false
        }
        
        guard let appsflyerInfoPath = Bundle.main.path(forResource: "Appsflyer-Info", ofType: "plist") else {
            return false
        }
        
        guard let amplitudeInfoPath = Bundle.main.path(forResource: "Amplitude-Info", ofType: "plist") else {
            return false
        }
        
        guard let sentryIoInfoPath = Bundle.main.path(forResource: "Sentry-io-Info", ofType: "plist") else {
            return false
        }
        
        let resourses = RepositoriesFactory.Resources(googleServiceInfo: googleServiceInfoPath,
                                                      appsflyerInfo: appsflyerInfoPath,
                                                      amplitudeInfo: amplitudeInfoPath,
                                                      sentryIoInfoPath: sentryIoInfoPath,
                                                      googleServiceInfoForWavesPlatform: googleServiceInfoPathWaves)
        let repositories = RepositoriesFactory(resources: resourses)
        
        let storages = StoragesFactory()
        
        Intercom.setApiKey("ios_sdk-5f049396b8a724034920255ca7645cadc3ee1920", forAppId:"ibdxiwmt")
                    
        
        UseCasesFactory.initialization(repositories: repositories,
                                       authorizationInteractorLocalizable: AuthorizationInteractorLocalizableImp(),
                                       storages: storages)
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func setupServices() {
        #if DEBUG || TEST
        
        SweetLogger.current.add(plugin: SweetLoggerConsole(visibleLevels: [.warning, .debug, .error, .network],
                                                           isShortLog: true))
        SweetLogger.current.visibleLevels = [.warning, .debug, .error, .network]
        
        #else
        SweetLogger.current.add(plugin: SweetLoggerSentry(visibleLevels: [.error]))
        SweetLogger.current.visibleLevels = [.warning, .debug, .error]
        
        #endif
    }
    
    class func shared() -> AppDelegate { UIApplication.shared.delegate as! AppDelegate }
    
    var menuController: RESideMenu { window?.rootViewController as! RESideMenu }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
