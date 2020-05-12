//
//  AddressesKeysAliacesCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 60
}

final class AddressesKeysAliacesCell: UITableViewCell, Reusable {
    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var infoButton: UIButton!
    private lazy var tapGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(handlerTapGesture(gesture:)))

    var infoButtonDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addGestureRecognizer(tapGesture)
        setupLocalization()
        infoButton.addTarget(self, action: #selector(actionTouchInfoButton(sender:)), for: .touchUpInside)
    }

    @objc func actionTouchInfoButton(sender _: UIButton) {
        infoButtonDidTap?()
    }

    @objc func handlerTapGesture(gesture _: UITapGestureRecognizer) {
        infoButtonDidTap?()
    }
}

// MARK: ViewConfiguration

extension AddressesKeysAliacesCell: ViewConfiguration {
    struct Model {
        let count: Int
    }

    // модель с 1 полем? зачем?
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
    static func viewHeight(model _: Model, width _: CGFloat) -> CGFloat {
        Constants.height
    }
}

// MARK: Localization

extension AddressesKeysAliacesCell: Localization {
    func setupLocalization() {
        titleLabel.text = Localizable.Waves.Addresseskeys.Cell.Aliases.title
    }
}
