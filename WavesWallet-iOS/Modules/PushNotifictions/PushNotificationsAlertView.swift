//
//  PushNotificationsAlertView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 07.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

class PushNotificationsAlertView: PopupActionView<Void> {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonActivate: HighlightedButton!
    @IBOutlet private weak var buttonLater: HighlightedButton!
    
    var activateAction:(() -> Void)?
    var laterAction:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLocalization()
    }
    
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Pushnotificationsalert.Label.title
        labelSubtitle.text = Localizable.Waves.Pushnotificationsalert.Label.subtitle
        buttonActivate.setTitle(Localizable.Waves.Pushnotificationsalert.Button.activatePush, for: .normal)
        buttonLater.setTitle(Localizable.Waves.Pushnotificationsalert.Button.later, for: .normal)
    }
    
    @IBAction private func laterTapped(_ sender: Any) {
        dismiss()
        laterAction?()
    }
    
    @IBAction private func activateTapped(_ sender: Any) {
        dismiss()
        activateAction?()
    }
}
