//
//  WalletUpdateAppView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/4/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let borderWith: CGFloat = 0.5
    static let deltaHeight: CGFloat = 16
}

final class UpdateAppView: UIView, NibLoadable {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!

    var viewTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.borderColor = UIColor.basic200.cgColor
        viewContainer.layer.borderWidth = Constants.borderWith
        setupLocalization()
    }

    @IBAction private func buttonTapped(_: Any) {
        viewTapped?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = viewContainer.frame.size.height + Constants.deltaHeight
    }
}

extension UpdateAppView: Localization {
    
    func setupLocalization() {
        labelTitle.text = Localizable.Waves.Wallet.Updateapp.Label.title
        labelSubtitle.text = Localizable.Waves.Wallet.Updateapp.Label.subtitle
    }
}
