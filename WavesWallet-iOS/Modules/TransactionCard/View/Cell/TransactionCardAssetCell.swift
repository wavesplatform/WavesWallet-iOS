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
import DomainLayer
import Extensions

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
                       style: .large)
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: ViewConfiguration

extension TransactionCardAssetCell: ViewConfiguration {

    func update(with model: Model) {
        
        titleLabel.text = Localizable.Waves.Transactioncard.Title.asset
        nameLabel.text = model.asset.displayName
        loadIcon(asset: model.asset)
    }
}

