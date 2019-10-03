//
//  EditAccountKeyboardControl.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class EditAccountKeyboardControl: UIView, NibLoadable {

    @IBOutlet private weak var buttonSave: UIButton!
    
    var dismissAction:(() -> Void)?
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                buttonSave.setupButtonActiveState()
            }
            else {
                buttonSave.setupButtonDeactivateState()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonSave.setTitle(Localizable.Waves.Neweditaccountname.Button.save, for: .normal)
    }
    
    @IBAction private func dismissKeyboard(_ sender: Any) {
        dismissAction?()
    }
}
