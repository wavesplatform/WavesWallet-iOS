//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Gloss
import IQKeyboardManagerSwift
import Moya
import RESideMenu
import SVProgressHUD
import UIKit

extension Locale {

    func log() {
        let currencySymbol = self.currencySymbol ?? ""
        let languageCode = self.languageCode ?? ""
        let calendarIdentifier = self.calendar.identifier

        print("currencySymbol \(currencySymbol) \(languageCode) \(calendarIdentifier)")
    }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
        SVProgressHUD.setOffsetFromCenter(UIOffsetMake(0, 40))
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        UIBarButtonItem.appearance().tintColor = UIColor.black

        showStartController()

        self.window?.makeKeyAndVisible()

        Locale.current.log()

        Locale(identifier: "en-RU").log()

        print(Locale.availableIdentifiers)

        return true
    }

    
    
    func showStartController() {
        self.window?.backgroundColor = AppColors.wavesColor
        let realm = WalletManager.getWalletsRealm()
        let w = realm.objects(WalletItem.self).filter("isLoggedIn == true")
        if w.count > 0 {
            WalletManager.didLogin(toWallet: w[0])
        } else {
            self.window!.rootViewController = StoryboardManager.launchViewController()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        WalletManager.clearPrivateMemoryKey()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let urlScheme = url.scheme, urlScheme == "waves" {
            OpenUrlManager.openUrl = url
            return true
        } else {
            return false
        }
    }

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var menuController: RESideMenu {
        return window?.rootViewController as! RESideMenu
    }
}
