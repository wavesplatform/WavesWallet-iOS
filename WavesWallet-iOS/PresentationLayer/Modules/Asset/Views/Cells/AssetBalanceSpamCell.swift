//
//  AssetBalanceSpamCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 174
}

final class AssetBalanceSpamCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelPerformAction: UILabel!
    @IBOutlet private weak var labelBalance: UILabel!
    @IBOutlet private weak var labelBalanceTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        labelPerformAction.text = Localizable.Waves.Asset.Cell.Assetinfo.cantPerformTransactions
        labelBalanceTitle.text = Localizable.Waves.Asset.Cell.Balance.avaliableBalance
    }
}

extension AssetBalanceSpamCell: ViewConfiguration {
    
    func update(with model: AssetTypes.DTO.Asset.Balance) {
        
        labelBalance.attributedText = NSAttributedString.styleForBalance(text: model.avaliableMoney.displayTextFull,
                                                                         font: labelBalance.font)
    }
}


extension AssetBalanceSpamCell: ViewHeight {
   
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
