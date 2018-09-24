//
//  SettingsViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 23/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import UILabel_Copyable
import RxSwift
import RxCocoa

class SettingsViewController: UITableViewController {

    @IBOutlet weak var myAddressLabel: UILabel!
    @IBOutlet weak var backupAttentionLabel: UILabel!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myAddressLabel.text = WalletManager.getAddress()
        myAddressLabel.copyingEnabled = true
        backupAttentionLabel.isHidden = WalletManager.currentWallet?.isBackedUp ?? false
    }

    override func viewWillAppear(_ animated: Bool) {
//        backupAttentionLabel.isHidden = WalletManager.currentWallet?.isBackedUp ?? false
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            if !WalletManager.isSeedRealmExist() {
                AskManager.askForSetPassword()
                    .flatMap{ pwd -> Observable<Void> in
                        return WalletManager.saveSeedRealm(password: pwd)
                    }
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { Void in
                        self.performSegue(withIdentifier: "BackupSeed", sender: nil)
                    }, onError: { err in
                        self.presentBasicAlertWithTitle(title: err.localizedDescription)
                    })
                    .disposed(by: bag)
            } else {
                performSegue(withIdentifier: "BackupSeed", sender: nil)
            }
        }
    }
}
