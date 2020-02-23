//
//  StakingTransferFeeInfoCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer
import RxSwift

final class StakingTransferFeeInfoCell: UITableViewCell, NibReusable {
    
    struct Model {
        let balance: DomainLayer.DTO.Balance
    }
        
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var balanceLabel: BalanceLabel!
            
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewConfiguration

extension StakingTransferFeeInfoCell: ViewConfiguration {
    
    func update(with model: StakingTransferFeeInfoCell.Model) {
                    
        balanceLabel.update(with: .init(balance: model.balance,
                                        sign: nil,
                                        style: .small))
    }
}

