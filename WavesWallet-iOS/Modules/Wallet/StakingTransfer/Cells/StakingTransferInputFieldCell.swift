//
//  StakingTransferInputField.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer
import TTTAttributedLabel

final class StakingTransferInputFieldCell: UITableViewCell, NibReusable {
    
    struct Model: Hashable {
                
        let title: NSAttributedString        
        let balance: BalanceInputField.Model
        let hasDecimal: Bool
    }
    
    @IBOutlet private weak var balanceInputField: BalanceInputField!
    @IBOutlet private weak var titleLabel: TTTAttributedLabel!
            
    var didSelectLinkWith: ((URL) -> Void)?
    var didChangeInput: ((_ value: Money?) -> Void)? {
        didSet {
            balanceInputField.didChangeInput = didChangeInput
        }
    }
    
    var didTapButtonDoneOnKeyboard: (() -> Void)? {
        didSet {
            balanceInputField.didTapButtonDoneOnKeyboard = didTapButtonDoneOnKeyboard
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.activeLinkAttributes = NSMutableAttributedString.urlAttributted()
        titleLabel.linkAttributes = NSMutableAttributedString.urlAttributted()
        titleLabel.delegate = self
        balanceInputField.didChangeInput = didChangeInput
    }
        
    override func becomeFirstResponder() -> Bool {
        return balanceInputField.becomeFirstResponder()
    }
}

// MARK: ViewConfiguration

extension StakingTransferInputFieldCell: ViewConfiguration {
    
    func update(with model: StakingTransferInputFieldCell.Model) {
        
        if model.hasDecimal {
            balanceInputField.setKeyboardType(.decimalPad)
        } else {
            balanceInputField.setKeyboardType(.numberPad)
        }
        titleLabel.text = model.title
        titleLabel.addLinks(from: model.title)
        balanceInputField.update(with: model.balance)
    }
}

// MARK: TTTAttributedLabelDelegate

extension StakingTransferInputFieldCell: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        self.didSelectLinkWith?(url)
    }
}
