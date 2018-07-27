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
    
 
    func setupCell(_ model: DexTypes.DTO.DexListModel) {
        labelTitle.text = model.amountAssetName + " / " + model.priceAssetName
        
        if model.percent == 0 {
            iconArrow.image = UIImage(named: "chartarrow22Accent100")
            labelPercent.text = String(model.percent) + "%"
        }
        else if model.percent > 0 {
            iconArrow.image = UIImage(named: "chartarrow22Success400")
            labelPercent.text = "+ " + String(model.percent) + "%"
        }
        else {
            iconArrow.image = UIImage(named: "chartarrow22Error500")
            labelPercent.text = "- " + String(model.percent * -1) + "%"
        }
    }
}
