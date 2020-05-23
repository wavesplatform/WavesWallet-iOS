//
//  ZoomFlowLayout.swift
//  WavesUIKit
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

/// Zoom layout используется на экране BuyCryptoViewController
/// Этот layout необходим для отображения фиатных и крипто ассетов
/// Он является горизонтальным. При необходимости есть возможность немного его переделать чтобы можно было использовать и для вертикального положения
public final class ZoomFlowLayout: UICollectionViewFlowLayout {
    private enum Constants {
        static let startScallingOffset: CGFloat = 50
        static let minimumScaleCoef: CGFloat = 0.3
    }

    public override func prepare() {
        guard let collectionView = collectionView else { return }
        scrollDirection = .horizontal

        collectionView.decelerationRate = .fast

        let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    }

    public override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []

        let newLayoutAttributes = layoutAttributes.compactMap { layoutAttributesForItem(at: $0.indexPath) }

        return newLayoutAttributes
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttribute = super.layoutAttributesForItem(at: indexPath)

        guard let collectionView = collectionView,
            let newLayoutAttribute = layoutAttribute?.copy() as? UICollectionViewLayoutAttributes else { return layoutAttribute }

        let currentContentOffset = collectionView.contentOffset

        let visibleRect = CGRect(x: currentContentOffset.x,
                                 y: currentContentOffset.y,
                                 width: collectionView.bounds.width,
                                 height: collectionView.bounds.height)

        let centerXOfVisibleRect = visibleRect.midX

        let distanceFromCenter = centerXOfVisibleRect - newLayoutAttribute.center.x
        let absDistanceFromCenter = min(abs(distanceFromCenter), Constants.startScallingOffset)

        let scaleCoef = absDistanceFromCenter * (Constants.minimumScaleCoef - 1) / Constants.startScallingOffset

        newLayoutAttribute.alpha = 1 - abs(scaleCoef)

        let scaleFactor = 1 - abs(scaleCoef) / 2
        newLayoutAttribute.transform3D = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1)

        return newLayoutAttribute
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                             withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        let collectionViewSize = collectionView.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x,
                                  y: 0,
                                  width: collectionViewSize.width,
                                  height: collectionViewSize.height)

        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect)?
            .filter({ $0.representedElementCategory == .cell }) else { return proposedContentOffset }

        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2

        for attributes in layoutAttributes {
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }

            if abs(attributes.center.x - proposedContentOffsetCenterX) <
                abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }

        if candidateAttributes == nil {
            return proposedContentOffset
        }

        var newOffsetX = candidateAttributes!.center.x - (collectionView.bounds.size.width / 2)

        let offset = newOffsetX - collectionView.contentOffset.x

        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = itemSize.width + minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }

        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
}
