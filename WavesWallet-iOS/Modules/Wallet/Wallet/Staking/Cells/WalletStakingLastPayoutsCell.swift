    //
//  WalletStakingLastPayoutsCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let collectionViewSpacing: CGFloat = 16
    static let contentInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
}

final class WalletStakingLastPayoutsCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var lastPayouts: [WalletTypes.DTO.Staking.Payout] = []
    private var currentIndex: Int = 0

    var didSelectPayout:((WalletTypes.DTO.Staking.Payout) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.contentInset = Constants.contentInset
        collectionView.isPagingEnabled = true
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = Constants.collectionViewSpacing
    }
}

extension WalletStakingLastPayoutsCell: ViewConfiguration {
    
    func update(with model: [WalletTypes.DTO.Staking.Payout]) {
        lastPayouts = model
        collectionView.reloadData()
    }
}

extension WalletStakingLastPayoutsCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return WalletStakingPayoutCollectionViewCell.viewHeight()
    }
}

// MARK: UICollectionViewDelegate

extension WalletStakingLastPayoutsCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        didSelectPayout?(lastPayouts[indexPath.row])
        collectionView.scrollToItem(at:indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }
    
}

// MARK: UICollectionViewDelegate

extension WalletStakingLastPayoutsCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - Constants.contentInset.left * 2,
                      height: WalletStakingPayoutCollectionViewCell.viewHeight())
    }
}

// MARK: UICollectionViewDataSource

extension WalletStakingLastPayoutsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastPayouts.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: WalletStakingPayoutCollectionViewCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)

        cell.update(with: lastPayouts[indexPath.row])

        return cell
    }
}

extension WalletStakingLastPayoutsCell: UIScrollViewDelegate {
    
    //TODO: Duplicate code from AssetTransactionsCell.swift
    
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
