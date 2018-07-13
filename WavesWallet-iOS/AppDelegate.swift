//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import Gloss
import RESideMenu


typealias Decodable = Gloss.Decodable

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        IQKeyboardManager.shared.enable = true
        
        showStartController()
        
        SVProgressHUD.setOffsetFromCenter(UIOffsetMake(0, 40))
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        UIBarButtonItem.appearance().tintColor = UIColor.black
        
//        let hello = StoryboardManager.HelloStoryboard().instantiateViewController(withIdentifier: "HelloLanguagesViewController") as! HelloLanguagesViewController
        
        let enter = StoryboardManager.EnterStoryboard().instantiateViewController(withIdentifier: "ConfirmBackupViewController") as! ConfirmBackupViewController
        
        let save = StoryboardManager.EnterStoryboard().instantiateViewController(withIdentifier: "SaveBackupPhraseViewController") as! SaveBackupPhraseViewController
        let nav = UINavigationController(rootViewController: save)

        let menuController = StoryboardManager.MainStoryboard().instantiateViewController(withIdentifier: "MenuViewController")
        let sideMenuViewController = RESideMenu(contentViewController: nav, leftMenuViewController: menuController, rightMenuViewController: nil)!
        sideMenuViewController.view.backgroundColor = menuController.view.backgroundColor
        sideMenuViewController.contentViewShadowOffset = CGSize(width: 0, height: 10)
        sideMenuViewController.contentViewShadowOpacity = 0.2
        sideMenuViewController.contentViewShadowRadius = 15
        sideMenuViewController.contentViewShadowEnabled = true
        sideMenuViewController.panGestureEnabled = false
        window?.rootViewController = sideMenuViewController
        
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

}

