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
import UITools

final class PayoutsFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        initialSetup()
        super.prepare()
    }

    private func initialSetup() {
        sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        minimumInteritemSpacing = 8
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) else { return nil }

        return attributesArray.compactMap { layoutAttributesForItem(at: $0.indexPath) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        guard let collectionView = collectionView else { return attributes }

        let itemWidth = collectionView.bounds.width - (sectionInset.left + sectionInset.right)
        let itemHeight = collectionView.bounds.height - (sectionInset.top + sectionInset.bottom)

        attributes.frame = CGRect(x: attributes.frame.origin.x,
                                  y: 0,
                                  width: itemWidth,
                                  height: itemHeight)

        return attributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity _: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width,
                                height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }
}

// TODO: Copy/Paste from AssetTransactionsCell
final class StakingLastPayoutsCell: UITableViewCell, NibReusable {
    private enum Constants {
        static let collectionViewSpacing: CGFloat = 16

        /// Магический коэффициент чтобы при скроле карточек расчитать верный уклон пользователя (подобран вручную + stackOverflow)
        static let scrollСoef: CGFloat = 0.5
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!

    private var lastPayouts: [PayoutTransactionVM] = []
    private var currentIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView.decelerationRate = .fast
        collectionView.registerCell(type: PayoutsTransactionCollectionViewCell.self)
        collectionView.contentInsetAdjustmentBehavior = .always

        collectionView.dataSource = self
        collectionView.delegate = self

//        collectionView.isPagingEnabled = true
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
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
}

// MARK: UICollectionViewDataSource

extension StakingLastPayoutsCell: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
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

extension StakingLastPayoutsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
