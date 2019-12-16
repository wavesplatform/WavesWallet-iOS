//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Exchange. All rights reserved.
//

import RESideMenu
import RxSwift
import IQKeyboardManagerSwift
import UIKit

import AppsFlyerLib

import WavesSDKExtensions
import WavesSDK
import WavesSDKCrypto

import Extensions
import DomainLayer
import DataLayer
import Firebase
import FirebaseMessaging

#if DEBUG || TEST
import AppSpectorSDK
#endif

#if DEBUG
import SwiftMonkeyPaws
#endif

#if DEBUG
enum UITest {
    static var isEnabledonkeyTest: Bool {
        return CommandLine.arguments.contains("--MONKEY_TEST")
    }
}
#endif

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var disposeBag: DisposeBag = DisposeBag()
    var window: UIWindow?

    var appCoordinator: AppCoordinator!
    lazy var migrationInteractor: MigrationUseCaseProtocol = UseCasesFactory.instance.migration
     
    #if DEBUG 
    var paws: MonkeyPaws?
    #endif
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var url: URL?
        
        if let path = launchOptions?[.url] as? String {
            url = URL(string: path)
        }
        
        if let scheme = url?.scheme, DeepLink.scheme != scheme {
            return false
        }
                
        var deepLink: DeepLink? = nil
        
        if let url = url {
            deepLink = DeepLink(url: url)
        }
        
        guard setupLayers() else { return false }
        
        setupUI()
        setupServices()
        
        let router = WindowRouter.windowFactory(window: self.window!)
        
        appCoordinator = AppCoordinator(router, deepLink: deepLink)

        migrationInteractor
            .migration()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in

            }, onError: { (_) in

            }, onCompleted: {
                self.appCoordinator.start()
                
            })
            .disposed(by: disposeBag)
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
                
        if DeepLink.scheme != url.scheme {
            return false
        }
        
        self.appCoordinator.openURL(link: DeepLink(url: url))
                
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoordinator.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        appCoordinator.applicationDidBecomeActive()        
        AppsFlyerTracker.shared().trackAppLaunch()
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate {
    
    func setupUI() {
        Swizzle(initializers: [UIView.passtroughInit, UIView.insetsInit, UIView.shadowInit]).start()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .basic50
        
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
                                                      sentryIoInfoPath: sentryIoInfoPath)
        let repositories = RepositoriesFactory(resources: resourses)
        
        UseCasesFactory.initialization(repositories: repositories, authorizationInteractorLocalizable: AuthorizationInteractorLocalizableImp())

        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func setupServices() {
        #if DEBUG || TEST
        
        SweetLogger.current.add(plugin: SweetLoggerConsole(visibleLevels: [.warning, .debug, .error, .network],
                                                           isShortLog: true))
        SweetLogger.current.visibleLevels = [.warning, .debug, .error, .network]
        
        AppsFlyerTracker.shared()?.isDebug = false
        
        if let path = Bundle.main.path(forResource: "AppSpector-Info", ofType: "plist"),
            let apiKey = NSDictionary(contentsOfFile: path)?["API_KEY"] as? String {
            let config = AppSpectorConfig(apiKey: apiKey)
            AppSpector.run(with: config)
        }

        #else
        SweetLogger.current.add(plugin: SweetLoggerSentry(visibleLevels: [.error]))
        SweetLogger.current.visibleLevels = [.warning, .debug, .error]
        AppsFlyerTracker.shared()?.isDebug = false
        #endif
    }

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var menuController: RESideMenu {
        return self.window?.rootViewController as! RESideMenu
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

}
