//
//  SettingsViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 23/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import UILabel_Copyable

class SettingsViewController: UITableViewController {

    @IBOutlet weak var myAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myAddressLabel.text = WalletManager.getAddress()
        myAddressLabel.copyingEnabled = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BackupSeedWordsViewController {
            vc.startVc = self
        }
    }
    @IBAction func onLogout(_ sender: Any) {
        WalletManager.didLogout()
    }
    
    @IBAction func onSupport(_ sender: Any) {
        let email = "support@wavesplatform.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.openURL(url)
        }
    }
}
