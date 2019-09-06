//
//  ConfirmRequestKeyValueCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class ConfirmRequestKeyValueCell: UITableViewCell, Reusable {
    
    struct Model {
        let title: String
        let value: String
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestKeyValueCell: ViewConfiguration {
    
    func update(with model: Model) {
        self.titleLabel.text = model.title
        self.valueLabel.text = model.value
    }
}
