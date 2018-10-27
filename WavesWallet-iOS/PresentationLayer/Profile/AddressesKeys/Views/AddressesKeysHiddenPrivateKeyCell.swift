//
//  AddressesKeysPrivateKeyCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 94
}

final class AddressesKeysHiddenPrivateKeyCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var showButton: UIButton!

    var showButtonDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        showButton.addTarget(self, action: #selector(actionTouchUpShowButton(sender:)), for: .touchUpInside)
    }

    @objc private func actionTouchUpShowButton(sender: UIButton) {
        showButtonDidTap?()    
    }
}

// MARK: ViewConfiguration

extension AddressesKeysHiddenPrivateKeyCell: ViewConfiguration {
    func update(with model: Void) {}
}

// MARK: ViewCalculateHeight

extension AddressesKeysHiddenPrivateKeyCell: ViewCalculateHeight {

    static func viewHeight(model: Void, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}

// MARK: Localization

extension AddressesKeysHiddenPrivateKeyCell: Localization {

    func setupLocalization() {
        titleLabel.text = "Private key"
        showButton.setTitle("Show", for: .normal)
    }
}
