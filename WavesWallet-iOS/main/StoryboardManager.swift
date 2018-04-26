
//
//  StoryboardManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class StoryboardManager {
    
    class func TransferStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Transfer", bundle: nil)
    }
    
    class func MainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class func DexStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Dex", bundle: nil)
    }
    
    
    class func launchViewController() -> UIViewController {
        return UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "NavLaunchViewController")
    }
    
    class func mainTabBarViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController")
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = MainTabBarController()
    }
    
    class func didLogout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = launchViewController()
    }
}
