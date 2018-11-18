//
//  TokenBurnConfirmationIDView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TokenBurnConfirmationIDView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelIDLocalization: UILabel!
    @IBOutlet private weak var labelID: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var descriptionView: DottedRoundView!
    @IBOutlet private weak var bottomSeparateView: DottedLineView!
    
    private var hasDescription = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        labelIDLocalization.text = Localizable.Waves.Tokenburn.Label.id
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if hasDescription {
            heightConstraint.constant = descriptionView.frame.origin.y + descriptionView.frame.size.height
        }
        else {
            heightConstraint.constant = bottomSeparateView.frame.origin.y + bottomSeparateView.frame.size.height
        }
    }
}

//MARK: - ViewConfiguration
extension TokenBurnConfirmationIDView: ViewConfiguration {
    
    struct Model {
        let id: String
        let description: String
    }
    
    func update(with model: TokenBurnConfirmationIDView.Model) {
        
        hasDescription = model.description.count > 0

        labelID.text = model.id
        labelDescription.text = model.description
        descriptionView.isHidden = !hasDescription
        bottomSeparateView.isHidden = hasDescription
    }
}

//MARK: - NSLayoutConstraint
private extension TokenBurnConfirmationIDView {
    var heightConstraint : NSLayoutConstraint {
        return constraints.first(where: {$0.firstAttribute == NSLayoutAttribute.height})!
    }
}
