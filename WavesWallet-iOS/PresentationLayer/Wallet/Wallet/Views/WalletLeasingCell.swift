//
//  WalletLeasingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletLeasingCell: UITableViewCell, NibReusable {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}

extension WalletLeasingCell: ViewConfiguration {
    func update(with model: WalletTypes.DTO.Leasing.Transaction) {
        labelTitle.attributedText = .styleForBalance(text: model.balance.displayTextFull,
                                                     font: labelTitle.font)
    }
}
