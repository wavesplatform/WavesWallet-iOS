//
//  TransactionCardAssetCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 14/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

private enum Constants {
    static let icon = CGSize(width: 48, height: 48)
    static let sponsoredIcon = CGSize(width: 18, height: 18)
}

final class TransactionCardAssetCell: UITableViewCell, Reusable {

    struct Model {
        let asset: DomainLayer.DTO.Asset
    }

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var iconImageView: UIImageView!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func loadIcon(asset: DomainLayer.DTO.Asset) {

        disposeBag = DisposeBag()

        AssetLogo.logo(icon: asset.iconLogo,
                       style: AssetLogo.Style(size: Constants.icon,                                              
                                              font: UIFont.systemFont(ofSize: 15),
                                              specs: .init(isSponsored: asset.isSponsored,
                                                           hasScript: asset.hasScript,
                                                           size: Constants.sponsoredIcon)))
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: ViewConfiguration

extension TransactionCardAssetCell: ViewConfiguration {

    func update(with model: Model) {

        //TODO: Loc
        titleLabel.text = "Asset"
        nameLabel.text = model.asset.displayName
        loadIcon(asset: model.asset)
    }
}

