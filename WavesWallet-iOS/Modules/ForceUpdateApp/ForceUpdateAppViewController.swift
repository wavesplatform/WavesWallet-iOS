//
//  ForceUpdateAppViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 01.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import WavesSDK
import DomainLayer

final class ForceUpdateAppViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonUpdate: HighlightedButton!
    
    var data: DomainLayer.DTO.VersionUpdateData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
    }


    @IBAction private func updateTapped(_ sender: Any) {
        UIApplication.shared.openURLAsync(WavesSDKConstants.appstoreURL)
    }
    
    private func setupLocalization() {
                            
        labelTitle.text = Localizable.Waves.Forceupdate.Label.title
        labelSubtitle.text = Localizable.Waves.Forceupdate.Label.subtitle(self.data?.forceUpdateVersion ?? "")
        buttonUpdate.setTitle(Localizable.Waves.Forceupdate.Button.update, for: .normal)
    }
}
