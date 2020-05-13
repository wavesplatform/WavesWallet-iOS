//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools

private enum Constansts {
    static let height: CGFloat = 76
    static let lastCellOffset: CGFloat = 5
}

final class HistoryTransactionCell: UITableViewCell, Reusable {
    @IBOutlet private(set) var transactionView: HistoryTransactionView!

    class func cellHeight() -> CGFloat { Constansts.height }

    class func lastCellHeight() -> CGFloat { Constansts.height + Constansts.lastCellOffset }
}

extension HistoryTransactionCell: ViewConfiguration {
    func update(with model: SmartTransaction) {
        transactionView.update(with: model)
    }
}
