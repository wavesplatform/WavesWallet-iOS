//
//  TransactionCardActionsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import RxSwift
import UIKit
import UITools

final class TransactionCardPaymentView: UITableViewCell, NibLoadable {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    private var disposeBag: DisposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .captionRegular
        balanceLabel.font = .captionRegular
    }

    func setAssetIcon(_ icon: AssetLogo.Icon) {
        AssetLogo.logo(icon: icon,
                       style: .tiny20)
            .observeOn(MainScheduler.instance)
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setBalance(_ money: Money) {
        balanceLabel.text = "-\(money.displayText)"
    }
}
