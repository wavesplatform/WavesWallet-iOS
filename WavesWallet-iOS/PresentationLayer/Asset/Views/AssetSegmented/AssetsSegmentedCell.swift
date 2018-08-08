//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {

    struct Model {
        let icon: UIImage
        let isHiddenArrow: Bool
    }
    @IBOutlet private weak var imageViewIcon: UIImageView!
    @IBOutlet private weak var imageArrow: UIImageView!
}

extension AssetsSegmentedCell: ViewConfiguration {

    func update(with model: AssetsSegmentedCell.Model) {
        imageArrow.isHidden = model.isHiddenArrow
        imageViewIcon.image = model.icon
    }
}
