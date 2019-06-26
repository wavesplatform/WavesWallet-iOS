//
//  SendConfirmationRecipientView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let fullHeight: CGFloat = 76
    static let defaultHeight: CGFloat = 62
}

final class SendConfirmationRecipientView: UIView, NibOwnerLoadable {
    
    @IBOutlet private weak var labelSendTo: UILabel!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelSendTo.text = Localizable.Waves.Sendconfirmation.Label.sentTo
    }
    
}

extension SendConfirmationRecipientView: ViewConfiguration {
    
    struct Model {
        let name: String?
        let address: String
    }
    
    func update(with model: Model) {
        
        if let name = model.name {
            
            labelTitle.text = name
            labelSubtitle.text = model.address
            labelSubtitle.isHidden = false
            updateHeight(Constants.fullHeight)
        }
        else {
            labelTitle.text = model.address
            labelSubtitle.isHidden = true
            updateHeight(Constants.defaultHeight)
        }
    }
}


//MARK: - Change frame

private extension SendConfirmationRecipientView {
    
    func updateHeight(_ height: CGFloat) {
        heightConstraint.constant = height
    }
    
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}
