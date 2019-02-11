//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {

    enum Constants {
        static let sizeLogo = CGSize(width: 48, height: 48)
    }

    struct Model {
        let icon: DomainLayer.DTO.Asset.Icon
        let isHiddenArrow: Bool
    }

    @IBOutlet private var imageViewIcon: UIImageView!
    @IBOutlet private var imageArrow: UIImageView!
    private var task: DispatchWorkItem?

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
}

// MARK: ViewConfiguration

extension AssetsSegmentedCell: ViewConfiguration {

    func update(with model: AssetsSegmentedCell.Model) {
        imageArrow.isHidden = model.isHiddenArrow

        task = AssetLogo.logo(url: model.icon,
                                       style: .init(size: Constants.sizeLogo,
                                                    font: UIFont.systemFont(ofSize: 15),
                                                    border: nil)) { [weak self] image in
            self?.imageViewIcon.image = image
        }
    }
}
