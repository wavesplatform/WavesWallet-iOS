//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Kingfisher
import UIKit

private enum Constants {
    static let sizeLogo = CGSize(width: 48, height: 48)
}

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {

    struct Model {
        let icon: String
        let isHiddenArrow: Bool
    }

    @IBOutlet private var imageViewIcon: UIImageView!
    @IBOutlet private var imageArrow: UIImageView!
    private var task: RetrieveImageDiskTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
}

// MARK: ViewConfiguration

extension AssetsSegmentedCell: ViewConfiguration {

    func update(with model: AssetsSegmentedCell.Model) {
        imageArrow.isHidden = model.isHiddenArrow

        task = AssetLogo.logoFromCache(name: model.icon,
                                       style: .init(size: Constants.sizeLogo,
                                                    font: UIFont.systemFont(ofSize: 15),
                                                    border: nil)) { [weak self] image in
            self?.imageViewIcon.image = image
        }
    }
}
