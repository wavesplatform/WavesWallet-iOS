//
//  ConfirmRequestButtonsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class ConfirmRequestButtonsCell: UITableViewCell, Reusable {
    
    @IBOutlet private var rejectButton: UIButton!
    @IBOutlet private var approveButton: UIButton!
    
    var rejectButtonDidTap: (() -> Void)?
    var approveButtonDidTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        rejectButton.setTitle(Localizable.Waves.Keeper.Button.reject, for: .normal)
        approveButton.setTitle(Localizable.Waves.Keeper.Button.approve, for: .normal)
    }
    
    @IBAction func rejectHadlerTouch() {
        rejectButtonDidTap?()
    }
    
    @IBAction func approveHadlerTouch() {
        approveButtonDidTap?()
    }
}
