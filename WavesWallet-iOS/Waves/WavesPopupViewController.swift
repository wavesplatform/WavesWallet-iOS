//
//  WavesPopupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu

class WavesPopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendTapped(_ sender: Any) {

        let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesSendViewController") as! WavesSendViewController

        let menu = AppDelegate.shared().menuController
        let mainTabBar = menu.contentViewController as! MainTabBarController
        mainTabBar.setupLastScrollCorrectOffset()
        let nav = mainTabBar.selectedViewController as! UINavigationController
        nav.pushViewController(controller, animated: true)
        mainTabBar.setTabBarHidden(true, animated: true)
        
        dismissTapped(sender)
    }
    
    
    @IBAction func receiveTapped(_ sender: Any) {
        
//        let types: [Receive.ViewModel.State] = [.cryptoCurrency]
        let vc = ReceiveContainerModuleBuilder().build(input: nil)
        
        let menu = AppDelegate.shared().menuController
        let mainTabBar = menu.contentViewController as! MainTabBarController
        mainTabBar.setupLastScrollCorrectOffset()
        let nav = mainTabBar.selectedViewController as! UINavigationController
        nav.pushViewController(vc, animated: true)
        dismissTapped(sender)
    }
    
    
    @IBAction func exchangeTapped(_ sender: Any) {
    
    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        if let parent = parent as? PopupViewController {
            parent.dismissPopup()
        }
    }
    
    
    deinit {
        print(self.classForCoder, #function)
    }
    
}
