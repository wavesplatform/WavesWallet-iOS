//
//  AssetCollectionHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

final class AssetsSegmentedCell: UICollectionViewCell, NibReusable {

    enum Constants {
        static let sizeLogo = CGSize(width: 48, height: 48)
        static let sponsoredSize = CGSize(width: 18, height: 18)
    }

    struct Model {
        let icon: DomainLayer.DTO.Asset.Icon
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
                       style: AssetLogo.Style(size: Constants.sizeLogo,
                                              font: UIFont.systemFont(ofSize: 15),
                                              specs: .init(isSponsored: model.isSponsored,
                                                           hasScript: model.hasScript,
                                                           size: Constants.sponsoredSize)))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (image) in
                
                self?.imageViewIcon.image = image
            })
            .disposed(by: disposeBag)
    }
}
