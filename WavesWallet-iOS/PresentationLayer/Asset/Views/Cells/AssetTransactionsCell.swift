//
//  AssetLastTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
    static let height: CGFloat = 76
}

final class AssetTransactionsCell: UITableViewCell, Reusable {

    @IBOutlet private var collectionView: UICollectionView!

    fileprivate var transactions: [HistoryTransactionView.Transaction]?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .basic50
        collectionView.backgroundColor = .basic50
        collectionView.contentInset = Constants.contentInset
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension AssetTransactionsCell: ViewConfiguration {

    func update(with model: [AssetTypes.DTO.Transaction]) {
        //TODO: Update

        let asset = HistoryTransactionView.Transaction.Asset.init(isSpam: true, isGeneral: false, name: "test", balance: Money.init(100, 0))

        transactions = [HistoryTransactionView.Transaction(id: "1", kind: .receive(asset)), HistoryTransactionView.Transaction(id: "2", kind: .receive(asset)), HistoryTransactionView.Transaction(id: "4", kind: .receive(asset)), HistoryTransactionView.Transaction(id: "3", kind: .receive(asset))]
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDelegate

extension AssetTransactionsCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Did Select Row
    }

    
}

// MARK: UICollectionViewDelegate

extension AssetTransactionsCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: AssetTransactionsCell.cellHeight())
    }
}

// MARK: UICollectionViewDataSource

extension AssetTransactionsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: AssetTransactionCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)

        if let transaction = transactions?[indexPath.row] {
            cell.update(with: transaction)
        }

        return cell
    }
}
