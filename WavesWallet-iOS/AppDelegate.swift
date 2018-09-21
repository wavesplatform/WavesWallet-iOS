//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Gloss
import RESideMenu
import RxSwift
import SVProgressHUD
import UIKit
import Moya
import RealmSwift
import FirebaseCore
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var appCoordinator: AppCoordinator!
    var helloCoordinator: HelloCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()

        Language.load()
        UserDefaults.standard.set(false, forKey: "isTestEnvironment")
        UserDefaults.standard.synchronize()

        Swizzle(initializers: [UIView.passtroughInit,
                               UIView.roundedInit,
                               UIView.shadowInit]).start()

        SweetLogger.current.visibleLevels = [.debug, .error]

        self.window = UIWindow(frame: UIScreen.main.bounds)
//        IQKeyboardManager.shared.enable = false
        self.window?.backgroundColor = AppColors.wavesColor
        UIBarButtonItem.appearance().tintColor = UIColor.black

        appCoordinator = AppCoordinator(window!)
        appCoordinator.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        WalletManager.clearPrivateMemoryKey()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        if let urlScheme = url.scheme, urlScheme == "waves" {
            OpenUrlManager.openUrl = url
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
