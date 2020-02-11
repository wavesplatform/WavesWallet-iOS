//
//  WalletStakingLastPayoutsCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 68
}

final class WalletStakingLastPayoutsCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

extension WalletStakingLastPayoutsCell: ViewConfiguration {
    
    func update(with model: [WalletTypes.DTO.Staking.Payout]) {
     
        scrollView.subviews.forEach {$0.removeFromSuperview()}
        
        for payout in model {
            let view = WalletPayoutView.loadFromNib()
            scrollView.addSubview(view)
        }
    }
}

extension WalletStakingLastPayoutsCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
