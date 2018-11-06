//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryTransactionCell: UITableViewCell, Reusable {

    @IBOutlet private(set) var transactionView: HistoryTransactionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        transactionView.addTableCellShadowStyle()
        transactionView.cornerRadius = 4
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}

//TODO Model
extension HistoryTransactionCell: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.SmartTransaction) {
        transactionView.update(with: model)
    }
}

