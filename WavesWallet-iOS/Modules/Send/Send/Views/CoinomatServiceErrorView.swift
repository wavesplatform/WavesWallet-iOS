//
//  CoinomatServiceErrorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let spaceBetweenTitles: CGFloat = 6
    static let leftOffset: CGFloat = 32
}

final class CoinomatServiceErrorView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.Waves.Coinomat.temporarilyUnavailable
        labelSubtitle.text = Localizable.Waves.Coinomat.tryAgain
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var height: CGFloat = 0
        height += labelTitle.text?.maxHeight(font: labelTitle.font, forWidth: frame.size.width - Constants.leftOffset) ?? 0
        height += Constants.spaceBetweenTitles
        height += labelSubtitle.text?.maxHeight(font: labelSubtitle.font, forWidth: frame.size.width - Constants.leftOffset) ?? 0
        heightConstraint.constant = height
    }
}

private extension CoinomatServiceErrorView {
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}
