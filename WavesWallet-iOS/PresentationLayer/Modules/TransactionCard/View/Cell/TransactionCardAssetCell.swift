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

    private func loadIcon(icon: DomainLayer.DTO.Asset.Icon) {

        disposeBag = DisposeBag()

        AssetLogo.logo(icon: icon,
                       style: AssetLogo.Style(size: Constants.icon,
                                              sponsoredSize: nil,
                                              font: UIFont.systemFont(ofSize: 15),
                                              border: nil))
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
        loadIcon(icon: model.asset.iconLogo)
    }
}

