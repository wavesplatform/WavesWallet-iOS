//
//  NewAccountSecretPhraseViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class NewAccountSecretPhraseViewController: UIViewController {

    @IBOutlet weak var topLogoOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        if Platform.isIphone5 {
            topLogoOffset.constant = 118
        }
    }

    @IBAction func closeTapped(_ sender: Any) {
    
    }
    
    @IBAction func laterTapped(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "UseTouchIDViewController") as! UseTouchIDViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backupNowTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountBackupInfoViewController") as! NewAccountBackupInfoViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
