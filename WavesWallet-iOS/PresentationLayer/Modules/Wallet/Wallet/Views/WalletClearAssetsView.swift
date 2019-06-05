//
//  WalletClearAssetsView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/5/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let borderWith: CGFloat = 0.5
    static let deltaHeight: CGFloat = 16
}

final class WalletClearAssetsView: UIView, NibLoadable {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    var removeViewTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.borderColor = UIColor.basic200.cgColor
        viewContainer.layer.borderWidth = Constants.borderWith
        update(with: ())
    }

    @IBAction private func crossTapped(_ sender: Any) {
        removeViewTapped?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = viewContainer.frame.size.height + Constants.deltaHeight
    }
}

extension WalletClearAssetsView: ViewConfiguration {
    func update(with model: Void) {
        labelTitle.text = Localizable.Waves.Wallet.Clearassets.Label.title
        labelSubtitle.text = Localizable.Waves.Wallet.Clearassets.Label.subtitle
    }
}
