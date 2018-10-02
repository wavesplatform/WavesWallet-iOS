//
//  AssetLastTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
    static let height: CGFloat = 76
}

final class AssetTransactionsCell: UITableViewCell, Reusable {

    @IBOutlet private var collectionView: UICollectionView!

    fileprivate var transactions: [DomainLayer.DTO.SmartTransaction]?
    var transactionDidSelect: ((DomainLayer.DTO.SmartTransaction) -> Void)?

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

    func update(with model: [DomainLayer.DTO.SmartTransaction]) {
        self.transactions = model
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDelegate

extension AssetTransactionsCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tx = transactions?[indexPath.row] else { return }
        transactionDidSelect?(tx)
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
