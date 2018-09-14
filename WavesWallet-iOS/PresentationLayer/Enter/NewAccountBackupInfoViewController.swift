//
//  NewAccountBackupInfoViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class NewAccountBackupInfoViewController: UIViewController {

    @IBOutlet weak var topLogoOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Platform.isIphone5 {
            topLogoOffset.constant = 80
        }
    }

    
    @IBAction func understandTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SaveBackupPhraseViewController") as! SaveBackupPhraseViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    

}
