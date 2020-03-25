//
//  WalletStakingLastPayoutsCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

final class PayoutsFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }

    private func initialSetup() {
        minimumInteritemSpacing = 8
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) else { return nil }

        return attributesArray.compactMap { layoutAttributesForItem(at: $0.indexPath) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let collectionView = collectionView else { return attributes }

        let itemWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)

        attributes.frame = CGRect(x: attributes.frame.origin.x,
                                  y: 0,
                                  width: itemWidth,
                                  height: collectionView.frame.height)

        return attributes
    }
}

private enum Constants {
    static let collectionViewSpacing: CGFloat = 16
    static let contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
}

// TODO: Copy/Paste from AssetTransactionsCell
final class StakingLastPayoutsCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!

    private var lastPayouts: [PayoutTransactionVM] = []
    private var currentIndex = 0

    var didSelectPayout: ((PayoutTransactionVM) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView.registerCell(type: PayoutsTransactionCollectionViewCell.self)
        collectionView.contentInset = Constants.contentInset

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isPagingEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: ViewConfiguration

extension StakingLastPayoutsCell: ViewConfiguration {
    func update(with model: [PayoutTransactionVM]) {
        lastPayouts = model
        collectionView.reloadData()
        
        // необходимо чтоб список не поехал в сторону (временное решение)
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
}

// MARK: UICollectionViewDelegate

extension StakingLastPayoutsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectPayout?(lastPayouts[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension StakingLastPayoutsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lastPayouts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PayoutsTransactionCollectionViewCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)

        if let viewModel = lastPayouts[safe: indexPath.row] {
            cell.update(with: viewModel)
        }
        
        return cell
    }
}

extension StakingLastPayoutsCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        let factor: CGFloat = 0.5 // magic number
        
        let cellSize = collectionView.frame.width - (Constants.contentInset.left + Constants.contentInset.right)
        
        let nextItem = Int(scrollView.contentOffset.x / cellSize + factor)
        
        let indexPath = IndexPath(row: nextItem, section: 0)
        
        collectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
