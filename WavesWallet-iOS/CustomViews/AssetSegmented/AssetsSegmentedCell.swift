//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxSwift
import UIKit
import UITools

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {
    struct Model {
        let icon: AssetLogo.Icon
        let isHiddenArrow: Bool
        let isSponsored: Bool
        let hasScript: Bool
    }

    @IBOutlet private var imageViewIcon: UIImageView!
    @IBOutlet private var imageArrow: UIImageView!
    private var disposeBag: DisposeBag = DisposeBag()
    private var model: AssetsSegmentedCell.Model?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewIcon.image = nil
        disposeBag = DisposeBag()
    }
}

// MARK: ViewConfiguration

extension AssetsSegmentedCell: ViewConfiguration {
    func update(with model: AssetsSegmentedCell.Model) {
        imageArrow.isHidden = model.isHiddenArrow

        self.model = model

        AssetLogo.logo(icon: model.icon,
                       style: .large)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                self.imageViewIcon.image = image
            })
            .disposed(by: disposeBag)
    }
}
