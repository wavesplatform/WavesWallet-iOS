//
//  AddressesKeysAliacesCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 60
}

final class AddressesKeysAliacesCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var infoButton: UIButton!

    var infoButtonDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        infoButton.addTarget(self, action: #selector(actionTouchInfoButton(sender:)), for: .touchUpInside)
    }

    @objc func actionTouchInfoButton(sender: UIButton) {
        infoButtonDidTap?()
    }
}

// MARK: ViewConfiguration

extension AddressesKeysAliacesCell: ViewConfiguration {

    struct Model {
        let count: Int
    }

    func update(with model: AddressesKeysAliacesCell.Model) {

        if model.count == 0 {
            subTitleLabel.text = Localizable.Waves.Addresseskeys.Cell.Aliases.Subtitle.withoutaliaces
        } else {
            subTitleLabel.text = Localizable.Waves.Addresseskeys.Cell.Aliases.Subtitle.withaliaces(model.count)
        }
    }
}

// MARK: ViewCalculateHeight

extension AddressesKeysAliacesCell: ViewCalculateHeight {

    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}


// MARK: Localization

extension AddressesKeysAliacesCell: Localization {

    func setupLocalization() {
        self.titleLabel.text = Localizable.Waves.Addresseskeys.Cell.Privatekey.title
    }
}
