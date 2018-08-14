//
//  DexMarketCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexMarketCell: UITableViewCell, Reusable {

    @IBOutlet weak var buttonInfo: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var iconCheckmark: UIImageView!
    
    var buttonInfoDidTap: (() -> Void)?
    
    @IBAction func buttonInfoTapped(_ sender: Any) {
        buttonInfoDidTap?()
    }
    
}

extension DexMarketCell: ViewConfiguration {
    
    func update(with model: DexMarket.DTO.Pair) {
        labelTitle.text = model.amountAsset.shortName + " / " + model.priceAsset.shortName
        labelSubtitle.text = model.amountAsset.name + " / " + model.priceAsset.name
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image
    }
    
}
