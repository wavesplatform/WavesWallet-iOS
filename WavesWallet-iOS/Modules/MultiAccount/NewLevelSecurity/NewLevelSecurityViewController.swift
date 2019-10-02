//
//  NewLevelSecurityViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/25/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class NewLevelSecurityViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonStart: UIButton!
     
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.isNavigationBarHidden = true
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Newlevelsecurity.Label.title
        labelSubtitle.text = Localizable.Waves.Newlevelsecurity.Label.subtitle
        buttonStart.setTitle(Localizable.Waves.Newlevelsecurity.Button.start, for: .normal)
    }

    @IBAction private func startTapped(_ sender: Any) {
    
        let vc = MigrateAccountsModuleBuilder().build()
        navigationController?.pushViewController(vc, animated: true)
    }
}
