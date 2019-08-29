//
//  ConfirmRequestFromToCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions

private enum Constants {
    
}

final class ConfirmRequestFromToCell: UITableViewCell, Reusable {
    
    struct Model {
        let address: String
        let dAppIcon: String
        let dAppName: String
    }
    
    @IBOutlet private var fromTitleLabel: UILabel!
    @IBOutlet private var fromIconImageView: UIImageView!
    @IBOutlet private var fromNameLabel: UIImageView!
    
    @IBOutlet private var toTitleLabel: UILabel!
    @IBOutlet private var toIconImageView: UIImageView!
    @IBOutlet private var toNameLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestFromToCell: ViewConfiguration {
    
    func update(with model: Model) {
//        self.firstLabel.text = model.firstTitle
//        self.secondLabel.attributedText = model.secondTitle
    }
}

