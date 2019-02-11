//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Kingfisher
import UIKit

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {

    enum Constants {
        static let sizeLogo = CGSize(width: 48, height: 48)
        static let sponsoredSize = CGSize(width: 18, height: 18)
    }

    struct Model {
        let icon: String
        let isHiddenArrow: Bool
        let isSponsored: Bool
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

        let sponsoredSize = model.isSponsored ? Constants.sponsoredSize : nil
        task = AssetLogo.logoFromCache(name: model.icon,
                                       style: .init(size: Constants.sizeLogo,
                                                    sponsoredSize: sponsoredSize,
                                                    font: UIFont.systemFont(ofSize: 15),
                                                    border: nil)) { [weak self] image in
            self?.imageViewIcon.image = image
        }
    }
}
