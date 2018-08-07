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
        labelTitle.text = model.amountAssetName + " / " + model.priceAssetName
       
        let firstPrice = MoneyUtil.value(model.firstPrice)
        let lastPrice = MoneyUtil.value(model.lastPrice)

        labelValue.text = MoneyUtil.getScaledText(model.lastPrice.amount, decimals: model.lastPrice.decimals)
        
        let percent = (lastPrice - firstPrice) * 100 / lastPrice
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

fileprivate extension MoneyUtil {
    static func value(_ from: Money) -> Double {
        return Double(from.amount) / pow(10, from.decimals).doubleValue
    }
}
