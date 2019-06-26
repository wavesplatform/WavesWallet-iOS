//
//  AddressesKeysAliacesCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 108
}

final class MyAddressAliacesCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var infoButton: UIButton!

    var infoButtonDidTap: (() -> Void)?
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlerTapGesture(gesture:)))

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        viewContainer.addGestureRecognizer(tapGesture)
        viewContainer.addTableCellShadowStyle()
        infoButton.addTarget(self, action: #selector(actionTouchInfoButton(sender:)), for: .touchUpInside)
    }

    @objc func actionTouchInfoButton(sender: UIButton) {
        infoButtonDidTap?()
    }

    @objc func handlerTapGesture(gesture: UITapGestureRecognizer) {
        infoButtonDidTap?()
    }
}

// MARK: ViewConfiguration

extension MyAddressAliacesCell: ViewConfiguration {

    struct Model {
        let count: Int
    }

    func update(with model: MyAddressAliacesCell.Model) {

        if model.count == 0 {
            subTitleLabel.text = Localizable.Waves.Myaddress.Cell.Aliases.Subtitle.withoutaliaces
        } else {
            subTitleLabel.text = Localizable.Waves.Myaddress.Cell.Aliases.Subtitle.withaliaces(model.count)
        }
    }
}

// MARK: ViewHeight

extension MyAddressAliacesCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}


// MARK: Localization

extension MyAddressAliacesCell: Localization {

    func setupLocalization() {
        self.titleLabel.text = Localizable.Waves.Myaddress.Cell.Aliases.title
    }
}
