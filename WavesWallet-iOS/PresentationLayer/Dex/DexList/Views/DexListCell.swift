//
//  DexListCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexListCell: UITableViewCell, Reusable {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var iconArrow: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPercent: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelType: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 70
    }
}

extension DexListCell: ViewConfiguration {
    func update(with model: DexList.DTO.Pair) {
        
        labelTitle.text = model.amountAsset.name + " / " + model.priceAsset.name

        labelType.text = Localizable.Waves.Dexlist.Label.price + " " + model.amountAsset.name
        
        let firstPrice = model.firstPrice.doubleValue
        let lastPrice = model.lastPrice.doubleValue

        labelValue.text = model.lastPrice.formattedText(defaultMinimumFractionDigits: true)
        
        let deltaPercent = (lastPrice - firstPrice) * 100
        let percent = deltaPercent != 0 ? deltaPercent / lastPrice : 0

        if percent == 0 {
            iconArrow.image = Images.chartarrow22Accent100.image
            labelPercent.text = String(format: "%.02f", percent) + "%"
        }
        else if percent > 0 {
            iconArrow.image = Images.chartarrow22Success400.image
            labelPercent.text = "+ " + String(format: "%.02f", percent) + "%"
        }
        else {
            iconArrow.image = Images.chartarrow22Error500.image
            labelPercent.text = "- " + String(format: "%.02f", percent * -1) + "%"
        }
    }
}
