//
//  DexChartCandlePriceView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexChartCandlePriceView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var bgViewPrice: UIView!
    @IBOutlet private weak var viewSeparator: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setup(textPrice: String, color: UIColor) {
        labelPrice.text = textPrice
        bgViewPrice.backgroundColor = color
        viewSeparator.backgroundColor = color
    }
    
}
