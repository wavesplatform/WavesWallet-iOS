//
//  DebugSwitchCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class DebugSwitchCell: UITableViewCell, Reusable {
    
    struct Model {
        let title: String
        let isOn: Bool
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var switchControl: UISwitch!
    
    var switchChangedValue: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: Action

private extension DebugSwitchCell {
    
    @IBAction func changedValue(sender: UISwitch) {
        switchChangedValue?(sender.isOn)
    }
}

// MARK: ViewConfiguration

extension DebugSwitchCell: ViewConfiguration {
    
    func update(with model: DebugSwitchCell.Model) {
        labelTitle.text = model.title
        switchControl.isOn = model.isOn
    }
}

