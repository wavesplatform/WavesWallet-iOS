//
//  LanguageTableCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let smallPading: CGFloat = 16
    static let bigPadding: CGFloat = 24
    static let height: CGFloat = 60
}

final class LanguageTableCell: UITableViewCell, NibReusable {
    
    struct Model {
        let icon: UIImage?
        let title: String
        let isOn: Bool
    }
    
    @IBOutlet fileprivate weak var iconLanguage: UIImageView!
    @IBOutlet fileprivate weak var labelTitle: UILabel!
    @IBOutlet fileprivate weak var iconCheckmark: UIImageView!

    @IBOutlet fileprivate weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var rightConstraint: NSLayoutConstraint!

    class func cellHeight() -> CGFloat {
        return Constants.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        iconLanguage.accessibilityIdentifier = AccessibilityIdentifiers.Cell.Languagetable.Icon.language
        iconCheckmark.accessibilityIdentifier = AccessibilityIdentifiers.Cell.Languagetable.Icon.checkmark.unselect
        labelTitle.accessibilityIdentifier = AccessibilityIdentifiers.Cell.Languagetable.title

        if Platform.isIphone5 {
            leftConstraint.constant = Constants.smallPading
            rightConstraint.constant = Constants.smallPading
        } else {
            leftConstraint.constant = Constants.bigPadding
            rightConstraint.constant = Constants.bigPadding
        }
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .white
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            selectedBackgroundView?.backgroundColor = .basic50
        } else {
            selectedBackgroundView?.backgroundColor = .white
        }
    }
}

extension LanguageTableCell: ViewConfiguration {
    
    func update(with model: LanguageTableCell.Model) {
        iconLanguage.image = model.icon
        labelTitle.text = model.title
        
        if model.isOn {
            iconCheckmark.accessibilityIdentifier = AccessibilityIdentifiers.Cell.Languagetable.Icon.Checkmark.select
            iconCheckmark.image = Images.on.image
        } else {
            iconCheckmark.image = Images.off.image
            iconCheckmark.accessibilityIdentifier = AccessibilityIdentifiers.Cell.Languagetable.Icon.checkmark.unselect
        }
    }
    
}
