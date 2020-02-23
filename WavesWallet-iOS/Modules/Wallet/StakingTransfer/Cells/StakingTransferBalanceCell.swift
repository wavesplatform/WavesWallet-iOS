//
//  StakingTransferBalance.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer
import RxSwift

final class StakingTransferBalanceCell: UITableViewCell, NibReusable {
    
    struct Model {
        let assetURL: AssetLogo.Icon
        let title: String
        let money: Money
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: Extension

extension StakingTransferBalanceCell: ViewConfiguration {
    
    func update(with model: StakingTransferBalanceCell.Model) {
                    
        self.titleLabel.text = model.title
        self.balanceLabel.text = model.money.displayText
        AssetLogo.logo(icon: model.assetURL,
                       style: .tiny)
            .observeOn(MainScheduler.instance)
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
    }
}
