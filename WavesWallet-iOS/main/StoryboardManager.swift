
//
//  StoryboardManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class StoryboardManager {
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
        default:
            return UIStoryboard(name: "Transactions", bundle: nil).instantiateViewController(withIdentifier: "GenericTransactionViewController")
        }
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
        appDelegate.window!.rootViewController = mainTabBarViewController()
    }
    
    class func didLogout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = launchViewController()
    }
}
