//
//  UICollectionView+Reusable.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public extension UICollectionView {
    enum SupplementaryViewKind {
        case header
        case footer
        var string: String {
            switch self {
            case .header: return UICollectionView.elementKindSectionHeader
            case .footer: return UICollectionView.elementKindSectionFooter
            }
        }
    }

    func registerCell<Cell>(type: Cell.Type) where Cell: UICollectionViewCell & NibReusable {
        register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    func registerCell<Cell>(type: Cell.Type) where Cell: UICollectionViewCell & Reusable {
        register(type, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    func dequeueCellForIndexPath<Cell>(indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell & Reusable {
        dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    @available(*, deprecated, message: "S from solid")
    func dequeueAndRegisterCell<Cell>(indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell & NibReusable {
        registerCell(type: Cell.self)
        return dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    @available(*, deprecated, message: "S from solid")
    func dequeueAndRegisterCell<Cell>(indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell & Reusable {
        registerCell(type: Cell.self)
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
        dequeueReusableSupplementaryView(ofKind: kind.string,
                                         withReuseIdentifier: Supplementary.reuseIdentifier,
                                         for: indexPath) as! Supplementary
    }
}
