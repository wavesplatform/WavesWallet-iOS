//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import RESideMenu
import RxSwift
import IQKeyboardManagerSwift
import UIKit
import Moya
import RealmSwift
import FirebaseCore
import FirebaseDatabase

import Fabric
import Crashlytics
import AppsFlyerLib
import Kingfisher

#if DEBUG || TEST
import AppSpectorSDK
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var disposeBag: DisposeBag = DisposeBag()
    var window: UIWindow?

    var appCoordinator: AppCoordinator!
    let migrationInteractor: MigrationInteractor = FactoryInteractors.instance.migrationInteractor

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path) {

            FirebaseApp.configure(options: options)
            Database.database().isPersistenceEnabled = false
            Fabric.with([Crashlytics.self])
        }
        
        if let path = Bundle.main.path(forResource: "Appsflyer-Info", ofType: "plist"),
            let root = NSDictionary(contentsOfFile: path)?["Appsflyer"] as? NSDictionary {
            if let devKey = root["AppsFlyerDevKey"] as? String,
                let appId = root["AppleAppID"] as? String {
                AppsFlyerTracker.shared().appsFlyerDevKey = devKey
                AppsFlyerTracker.shared().appleAppID = appId
            }
        }

        clearImageCache()
        
        IQKeyboardManager.shared.enable = true
        UIBarButtonItem.appearance().tintColor = UIColor.black

        Language.load()

        Swizzle(initializers: [UIView.passtroughInit, UIView.insetsInit, UIView.shadowInit]).start()

        #if DEBUG || TEST
            SweetLogger.current.plugins = [SweetLoggerConsole(visibleLevels: [],
                                                              isShortLog: true),
                                            SweetLoggerSentry(visibleLevels: [.error])]

            SweetLogger.current.visibleLevels = [.warning, .debug, .error]

            AppsFlyerTracker.shared()?.isDebug = false
        
            if let path = Bundle.main.path(forResource: "AppSpector-Info", ofType: "plist"),
                let apiKey = NSDictionary(contentsOfFile: path)?["API_KEY"] as? String {
                let config = AppSpectorConfig(apiKey: apiKey)
                AppSpector.run(with: config)                
            }

        #else
            SweetLogger.current.plugins = [SweetLoggerSentry(visibleLevels: [.error])]
            SweetLogger.current.visibleLevels = [.warning, .debug, .error]
            AppsFlyerTracker.shared()?.isDebug = false
        #endif

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .basic50
        
        appCoordinator = AppCoordinator(WindowRouter(window: self.window!))

        migrationInteractor
            .migration()
            .subscribe(onNext: { (_) in

            }, onError: { (_) in

            }, onCompleted: {
                self.appCoordinator.start()
            })
            .disposed(by: disposeBag)

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
    }

    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        if let urlScheme = url.scheme, urlScheme == "waves" {
//            OpenUrlManager.openUrl = url
            return true
        } else {
            return false
        }
    }
}

extension AppDelegate {

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var menuController: RESideMenu {
        return self.window?.rootViewController as! RESideMenu
    }
}
