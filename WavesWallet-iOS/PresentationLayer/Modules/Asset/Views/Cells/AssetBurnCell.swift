//
//  AssetBurnCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let defaultHeight: CGFloat = 56
    static let topOffset: CGFloat = 50
}

final class AssetBurnCell: UITableViewCell, NibReusable {

    struct Model {
        let isSpam: Bool
    }
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var topOffset: NSLayoutConstraint!
    
    var burnAction:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        labelTitle.text = Localizable.Waves.Tokenburn.Label.tokenBurn
    }
    
    @IBAction private func burnTapped(_ sender: Any) {
        burnAction?()
    }
}

extension AssetBurnCell: ViewConfiguration {
    func update(with model: AssetBurnCell.Model) {
        topOffset.constant = model.isSpam ? 0 : Constants.topOffset
    }
}

extension AssetBurnCell: ViewCalculateHeight {
    
    static func viewHeight(model: AssetBurnCell.Model, width: CGFloat) -> CGFloat {
        return model.isSpam ? Constants.defaultHeight : Constants.defaultHeight + Constants.topOffset
    }
}
