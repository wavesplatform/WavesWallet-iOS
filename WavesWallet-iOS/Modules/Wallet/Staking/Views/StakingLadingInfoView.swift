//
//  StakingLadingInfoView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

final class StakingLadingInfoView: UIView {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var subTitleLabel: UILabel!
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    @IBOutlet private weak var titleLabelTop: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
