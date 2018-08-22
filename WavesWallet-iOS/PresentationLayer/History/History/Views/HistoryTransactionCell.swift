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

extension HistoryTransactionCell: ViewConfiguration {
    
    func update(with model: HistoryTypes.DTO.Transaction) {
        transactionView.update(with: HistoryTransactionView.Transaction(with: model))
    }
    
}

fileprivate extension HistoryTransactionView.Transaction {
    init(with transaction: HistoryTypes.DTO.Transaction) {
        let kind = HistoryTransactionView.Transaction.Kind(rawValue: transaction.kind.rawValue)!
        
        self.init(id: transaction.id, name: transaction.name, balance: transaction.balance, kind: kind, tag: transaction.tag, date: transaction.date)
    }
}
