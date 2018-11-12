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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var disposeBag: DisposeBag = DisposeBag()
    var window: UIWindow?

    var appCoordinator: AppCoordinator!
    var migrationInteractor: MigrationInteractor = MigrationInteractor()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path) {

            FirebaseApp.configure(options: options)
            Database.database().isPersistenceEnabled = false
            Fabric.with([Crashlytics.self])
        }



        IQKeyboardManager.shared.enable = true
        UIBarButtonItem.appearance().tintColor = UIColor.black

        Language.load()
        
//        Swizzle(initializers: [UIView.passtroughInit,
//                               UIView.shadowInit]).start()
        Swizzle(initializers: [UIView.passtroughInit]).start()

        #if DEBUG
            SweetLogger.current.visibleLevels = []
        #else
            SweetLogger.current.visibleLevels = []
        #endif
//            [.debug, .network, .error]

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .basic50
        
        appCoordinator = AppCoordinator(window!)


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

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appCoordinator.applicationDidBecomeActive()
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
