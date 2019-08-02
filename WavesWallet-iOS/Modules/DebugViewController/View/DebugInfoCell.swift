//
//  DebugInfoCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 246
}

final class DebugInfoCell: UITableViewCell, Reusable {
    
    struct Model {
        let version: String
        let deviceId: String
    }
    
    @IBOutlet private weak var deleteButton: UIButton!
    
    @IBOutlet private weak var secondTitleLabel: UILabel!
    @IBOutlet private weak var versionTitleLabel: UILabel!
    
    @IBOutlet private weak var secondValueLabel: UILabel!
    @IBOutlet private weak var versionValueLabel: UILabel!
    
    var deleteButtonDidTap: (() -> Void)?
    
    class func cellHeight() -> CGFloat {
        return Constants.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.setBackgroundImage(UIColor.error400.image, for: .normal)
        deleteButton.setBackgroundImage(UIColor.error200.image, for: .highlighted)
        deleteButton.setBackgroundImage(UIColor.error100.image, for: .disabled)
    }
}

// MARK: Action

private extension DebugInfoCell {
    
    @IBAction func deleteAccount(sender: UIButton) {
        deleteButtonDidTap?()
    }    
}

// MARK: ViewConfiguration

extension DebugInfoCell: ViewConfiguration {
    
    func update(with model: DebugInfoCell.Model) {
        
        deleteButton.setTitle("Delete all data", for: .normal)
        
        secondTitleLabel.text = "Device ID"
        versionTitleLabel.text = "Version"
        
        secondValueLabel.text = model.deviceId
        versionValueLabel.text = model.version
    }
}


