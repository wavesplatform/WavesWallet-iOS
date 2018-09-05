
//
//  StoryboardManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu


class StoryboardManager {
    
    class func WavesStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Waves", bundle: nil)
    }
    
    class func TransferStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Transfer", bundle: nil)
    }
    
    class func MainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class func DexStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Dex", bundle: nil)
    }
    
    class func TransactionsStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Transactions", bundle: nil)
    }
    
    class func ProfileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    class func HelloStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Hello", bundle: nil)
    }
    
    class func EnterStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Enter", bundle: nil)
    }
    
    class func launchViewController() -> UIViewController {
        return UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "NavLaunchViewController")
    }
    
    class func transactionDetailViewController(tx: Transaction) -> UIViewController {
        switch tx.type {
        case 4:
           return UIStoryboard(name: "Transactions", bundle: nil).instantiateViewController(withIdentifier: "TransferTransactionViewController")
        case 7:
            return UIStoryboard(name: "Transactions", bundle: nil).instantiateViewController(withIdentifier: "ExchangeTransactionViewController")
        default:
            return UIStoryboard(name: "Transactions", bundle: nil).instantiateViewController(withIdentifier: "GenericTransactionViewController")
        }
    }
    
    class func assetPairDetailsViewController(item: NSDictionary) -> UIViewController {
        let vc = UIStoryboard(name: "Dex", bundle: nil).instantiateViewController(withIdentifier: "AssetPairDetailsViewController")
        if let nav = vc as? UINavigationController
            , let topVc = nav.topViewController as? AssetPairDetailsViewController {
            topVc.item = item
        }
        
        return vc;
    }
    
    class func sendViewController(asset: AssetBalance) -> SendViewController {
        let vc = UIStoryboard(name: "Transfer", bundle: nil).instantiateViewController(withIdentifier: "SendViewController") as! SendViewController
        vc.selectedAccount = asset
        return vc
    }
    
    
    class func receiveViewController(asset: AssetBalance) -> ReceiveViewController {
        let vc = UIStoryboard(name: "Transfer", bundle: nil).instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
        vc.selectedAccount = asset
        return vc
    }

    class func didEndLogin() {
        
        let menuController = MainStoryboard().instantiateViewController(withIdentifier: "MenuViewController")
        let sideMenuViewController = RESideMenu(contentViewController: MainTabBarController(), leftMenuViewController: menuController, rightMenuViewController: nil)!
        sideMenuViewController.view.backgroundColor = menuController.view.backgroundColor
        sideMenuViewController.contentViewShadowOffset = CGSize(width: 0, height: 10)
        sideMenuViewController.contentViewShadowOpacity = 0.2
        sideMenuViewController.contentViewShadowRadius = 15
        sideMenuViewController.contentViewShadowEnabled = true
        sideMenuViewController.panGestureEnabled = false
        sideMenuViewController.interactivePopGestureRecognizerEnabled = false
        sideMenuViewController.panFromEdge = false
        sideMenuViewController.interactivePopGestureRecognizerEnabled = true
        AppDelegate.shared().window?.rootViewController = sideMenuViewController
    }
    
    class func didLogout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = launchViewController()
    }
}
