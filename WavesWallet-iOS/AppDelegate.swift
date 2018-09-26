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
import FirebaseDatabase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var appCoordinator: AppCoordinator!
    lazy var database: DatabaseReference = Database.database().reference().child("/pincodes-ios-dev/")

    lazy var authenticationRepositoryRemote = AuthenticationRepositoryRemote()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path) {

            FirebaseApp.configure(options: options)
            Database.database().isPersistenceEnabled = false
            Fabric.with([Crashlytics.self])
        }

        Language.load()
        UserDefaults.standard.set(false, forKey: "isTestEnvironment")
        UserDefaults.standard.synchronize()

        Swizzle(initializers: [UIView.passtroughInit,
                               UIView.roundedInit,
                               UIView.shadowInit]).start()

        SweetLogger.current.visibleLevels = [.debug, .error, .network]

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = AppColors.wavesColor
        UIBarButtonItem.appearance().tintColor = UIColor.black


//        let button1 = UIButton.init(frame: CGRect.init(x: 10, y: 500, width: 100, height: 100))
//        button1.addTarget(self, action: #selector(megaButton), for: .touchUpInside)
//
//        button1.backgroundColor = .orange
//        button1.setTitle("Reg 2222", for: .normal)
//
//        let button2 = UIButton.init(frame: CGRect.init(x: 200, y: 500, width: 100, height: 100))
//        button2.addTarget(self, action: #selector(megaButton2), for: .touchUpInside)
//        button2.backgroundColor = .green
//        button2.setTitle("Auth 3333", for: .normal)
//
//        let button3 = UIButton.init(frame: CGRect.init(x: 200, y: 650, width: 100, height: 100))
//        button3.addTarget(self, action: #selector(megaButton3), for: .touchUpInside)
//        button3.backgroundColor = .green
//        button3.setTitle("Change password to 3333", for: .normal)
//        
//
//        let button = UIButton.init(frame: CGRect.init(x: 10, y: 100, width: 300, height: 300))
//        button.addTarget(self, action: #selector(megaButton1), for: .touchUpInside)
//        button.setTitle("Auth 2222", for: .normal)
//        button.backgroundColor = .red

//        FactoryInteractors.instance.wallets.registerWallet(DomainLayer.DTO.WalletRegistation.init(name: "test", address: "323 ", privateKey: PrivateKeyAccount.init(seed: []), isBackedUp: true, password: "3", passcode: "3")).subscribe()

//        window!.rootViewController = UIViewController()
//        window!.rootViewController?.view!.addSubview(button)
//        window!.rootViewController?.view!.addSubview(button1)
//        window!.rootViewController?.view!.addSubview(button2)
//        window!.rootViewController?.view!.addSubview(button3)
//        window!.makeKeyAndVisible()
        appCoordinator = AppCoordinator(window!)
        appCoordinator.start()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        WalletManager.clearPrivateMemoryKey()
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
