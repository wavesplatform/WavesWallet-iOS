//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        IQKeyboardManager.sharedManager().enable = true
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0.0, -1000.0), for: .default)
        
        showStartController()
        
        if (window?.rootViewController?.isKind(of: UITabBarController.classForCoder()))! {
            let tabBar = window?.rootViewController as! UITabBarController
            tabBar.selectedIndex = 3
        }
        
        return true
    }
    
    func testBase58() {
        let s = "trial appear battle what fiber hello weasel grunt spare heavy produce beach one friend sad"
        let b = "KFWy4MpQgRcaEAdjwr9KenkSWCKzEUCzK9SXWCFGD4KWYsXiKBhmjW2Dma996W5XV5esBJTELoTjF88C6QBNVRKenMjCzYWinbvWTfcbUfB5YjjxVVhrt9FUKRM"
        let b1 = "ZiCa"
        let r = Base58.decode(b1)
        let sr = String(data: Data(r), encoding: .utf8) ?? ""
        print(sr)
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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let urlScheme = url.scheme, urlScheme == "waves" {
            OpenUrlManager.openUrl = url
            return true
        } else {
            return false
        }
    }


}

