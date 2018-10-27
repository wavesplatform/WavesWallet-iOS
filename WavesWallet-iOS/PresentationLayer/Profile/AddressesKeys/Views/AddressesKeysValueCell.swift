//
//  AddressesKeysAddressCell.swift
//  
//
//  Created by mefilt on 26/10/2018.
//

import UIKit

private enum Constants {
    static let topPadding: CGFloat = 24
    static let bottomPadding: CGFloat = 24
    static let separatoHeight: CGFloat = 1
    static let titleKeyHeight: CGFloat = 14
    static let paddingTitleTop: CGFloat = 8
    static let leftOrRightPadding: CGFloat = 16
    static let infoButtonSize: CGFloat = 50
}

final class AddressesKeysValueCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var copyButton: PasteboardButton!


    override func awakeFromNib() {
        super.awakeFromNib()

        copyButton.copiedText = { [weak self] in
            return self?.subTitleLabel.text
        }
    }
}

// MARK: ViewConfiguration

extension AddressesKeysValueCell: ViewConfiguration {

    struct Model {
        let title: String
        let value: String
    }

    func update(with model: AddressesKeysValueCell.Model) {
        titleLabel.text = model.title
        subTitleLabel.text = model.value
    }
}

// MARK: ViewCalculateHeight

//TODO: Incorect paddint copy button 
extension AddressesKeysValueCell: ViewCalculateHeight {

    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {

        let size = model.value.maxHeightMultiline(font: .systemFont(ofSize: 13), forWidth: width - Constants.leftOrRightPadding - Constants.infoButtonSize)

        return Constants.topPadding + Constants.bottomPadding + Constants.separatoHeight + Constants.titleKeyHeight + size + Constants.paddingTitleTop
    }
}
