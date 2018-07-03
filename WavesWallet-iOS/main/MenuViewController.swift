//
//  MenuViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var firstOffset: NSLayoutConstraint!
    @IBOutlet weak var secondOffset: NSLayoutConstraint!
    @IBOutlet weak var bottomOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Platform.isIphone5 {
            firstOffset.constant = 0
            secondOffset.constant = 20
            bottomOffset.constant = 20
        }
    }
    
    @IBAction func wavesTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://wavescommunity.com")!)
    }
    
    @IBAction func gitTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://github.com/wavesplatform/")!)
    }
    
    @IBAction func telegramTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://telegram.me/wavesnews")!)
    }
    
    @IBAction func discordTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://discordapp.com/invite/cnFmDyA")!)
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://twitter.com/wavesplatform")!)
    }
    
    @IBAction func fbTapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.facebook.com/wavesplatform")!)
    }
    

}
