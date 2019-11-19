//
//  ForceUpdateAppViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 01.11.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import WavesSDK
import DomainLayer

final class ServerMaintenanceViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
                
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Servermaintenance.Label.title
        labelSubtitle.text = Localizable.Waves.Servermaintenance.Label.subtitle
    }
}
