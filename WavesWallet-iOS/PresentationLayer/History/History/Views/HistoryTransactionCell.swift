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
    
    class func cellHeight() -> CGFloat {
        return 76
    }
    
}

//TODO Model
extension HistoryTransactionCell: ViewConfiguration {
    
    func update(with model: GeneralTypes.DTO.Transaction) {
        transactionView.update(with: model)
    }
}

