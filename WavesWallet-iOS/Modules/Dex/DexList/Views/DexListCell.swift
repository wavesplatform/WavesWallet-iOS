//
//  DexListCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/24/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

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

        labelType.text = Localizable.Waves.Dexlist.Label.price + " " + model.priceAsset.name
        
        let firstPrice = model.firstPrice.doubleValue
        let lastPrice = model.lastPrice.doubleValue

        labelValue.text = model.lastPrice.displayText
                
        var deltaPercent: Double {
            if firstPrice > lastPrice {
                return (firstPrice - lastPrice) * 100
            }
            return (lastPrice - firstPrice) * 100
        }
        
        let percent = firstPrice != 0 ? deltaPercent / firstPrice : 0

        if lastPrice > firstPrice {
            iconArrow.image = Images.chartarrow22Success400.image
            labelPercent.text = String(format: "%.02f", percent) + "%"
        }
        else if firstPrice > lastPrice {
            iconArrow.image = Images.chartarrow22Error500.image
            labelPercent.text = String(format: "%.02f", percent * -1) + "%"
        }
        else {
            iconArrow.image = Images.chartarrow22Accent100.image
            labelPercent.text = String(format: "%.02f", percent) + "%"
        }
    }
}
