//
//  UICollectionView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UICollectionView {

    enum SupplementaryViewKind {
        case header
        case footer
        fileprivate var string: String {
            switch self {
            case .header:
                return UICollectionElementKindSectionHeader
            case .footer:
                return UICollectionElementKindSectionFooter
            }
        }
    }

    func registerCell<Cell>(type: Cell.Type)
        where Cell: UICollectionViewCell & NibReusable {
            register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    func registerCell<Cell>(type: Cell.Type)
        where Cell: UICollectionViewCell & Reusable {
            register(type, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    func dequeueCellForIndexPath<Cell>(indexPath: IndexPath) -> Cell
        where Cell: UICollectionViewCell & Reusable {
            return dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    func registerSupplementaryView<Supplementary>(type: Supplementary.Type,
                                                  kind: SupplementaryViewKind)
        where Supplementary: UICollectionReusableView & NibReusable {
            register(Supplementary.nib, forSupplementaryViewOfKind: kind.string, withReuseIdentifier: Supplementary.reuseIdentifier)
    }

    func registerSupplementaryView<Supplementary>(type: Supplementary.Type,
                                                  kind: SupplementaryViewKind)
        where Supplementary: UICollectionReusableView & Reusable {
            register(type, forSupplementaryViewOfKind: kind.string, withReuseIdentifier: Supplementary.reuseIdentifier)
    }

    func dequeueReusableSupplementaryViewOfKind<Supplementary>(kind: SupplementaryViewKind,
                                                               forIndexPath indexPath: IndexPath) -> Supplementary
        where Supplementary: UICollectionReusableView & Reusable {
            return dequeueReusableSupplementaryView(ofKind: kind.string, withReuseIdentifier: Supplementary.reuseIdentifier, for: indexPath) as! Supplementary
    }
}
