//
//  AssetTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 28.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetTransactionCell: UICollectionViewCell, NibReusable, ViewConfiguration {

    @IBOutlet private var transactionView: HistoryTransactionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = {
            let view = UIView()
            view.backgroundColor = .basic50
            return view
        }()
    }

    func update(with model: GeneralTypes.DTO.Transaction) {
        transactionView.update(with: model)
    }
}
