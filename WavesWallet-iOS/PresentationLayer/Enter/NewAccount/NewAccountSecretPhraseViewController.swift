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

        if Platform.isIphone5 {
            topLogoOffset.constant = 118
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func showPassCode() {
        let controller = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
        controller.isCreatePasswordMode = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        showPassCode()
    }
    
    @IBAction func laterTapped(_ sender: Any) {
        showPassCode()
    }
    
    @IBAction func backupNowTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountBackupInfoViewController") as! NewAccountBackupInfoViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
