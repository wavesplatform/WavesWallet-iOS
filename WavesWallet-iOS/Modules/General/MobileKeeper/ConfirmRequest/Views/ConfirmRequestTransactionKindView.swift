//
//  ConfirmRequestTransactionKindView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class ConfirmRequestTransactionKindView: UIView, NibOwnerLoadable {
    
    enum Info {
        case balance(BalanceLabel.Model)
        case descriptionLabel(String)
    }
    
    struct Model {
        let title: String
        let image: UIImage
        let info: Info
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!
    @IBOutlet private var iconImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestTransactionKindView: ViewConfiguration {
    
    func update(with model: Model) {
        
        switch model.info {
        case .balance(let model):
            self.infoLabel.isHidden = true
            self.balanceLabel.isHidden = false
            self.balanceLabel.update(with: model)
            
        case .descriptionLabel(let text):
            self.infoLabel.text = text
            self.infoLabel.isHidden = false
            self.balanceLabel.isHidden = true
        }
        
        self.iconImageView.image = model.image
        self.titleLabel.text = model.title
    }
}

