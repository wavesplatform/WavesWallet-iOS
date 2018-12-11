//
//  AssetLastTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let collectionViewSpacing: CGFloat = 16
    static let contentInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
    static let height: CGFloat = 76
}

final class AssetTransactionsCell: UITableViewCell, Reusable {

    @IBOutlet private var collectionView: UICollectionView!

    fileprivate var transactions: [DomainLayer.DTO.SmartTransaction]?
    var transactionDidSelect: ((DomainLayer.DTO.SmartTransaction) -> Void)?
    fileprivate var currentIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .basic50
        
        collectionView.backgroundColor = .basic50
        collectionView.contentInset = Constants.contentInset
        collectionView.isPagingEnabled = true
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = Constants.collectionViewSpacing
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
        
        collectionView.scrollToItem(at:indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
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

extension AssetTransactionsCell: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if abs(velocity.x) < abs(velocity.y) { return }
        
        targetContentOffset.pointee = scrollView.contentOffset
        let pageWidth: CGFloat = bounds.width - 32
        let minSpace: CGFloat = Constants.collectionViewSpacing
        var cellToSwipe: Double = Double(CGFloat(scrollView.contentOffset.x) / CGFloat(pageWidth + minSpace))
        
        // next
        if cellToSwipe > Double(currentIndex) {
            
            if cellToSwipe - Double(currentIndex) > 0 && velocity.x >= 0 {
                cellToSwipe += 1
            }

            // previous
        } else if cellToSwipe < Double(currentIndex) {
            
            if Double(currentIndex) - cellToSwipe > 0.1 && velocity.x <= 0 {
                cellToSwipe -= 1
                cellToSwipe = ceil(cellToSwipe)
            } else {
                cellToSwipe = ceil(cellToSwipe)
            }
            
        }
        
        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(collectionView.numberOfItems(inSection: 0)) {
            cellToSwipe = Double(collectionView.numberOfItems(inSection: 0)) - Double(1)
        }
        
        currentIndex = Int(cellToSwipe)
        let indexPath:IndexPath = IndexPath(row: currentIndex, section:0)
        collectionView.scrollToItem(at:indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
        
    }
    
}
