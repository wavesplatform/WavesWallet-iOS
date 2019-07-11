//
//  DexCreateOrderInvalidPriceView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 10.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class DexCreateOrderInvalidPriceView: PopupActionView<DexCreateOrderInvalidPriceView.Model> {
    
    struct Model {
        let pricePercent: Int
        let isPriceHigherMarket: Bool
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleTitleLabel: UILabel!
    @IBOutlet private weak var placeOrderButton: HighlightedButton!
    @IBOutlet private weak var buttonCancel: HighlightedButton!
    
    var buttonDidTap: ((_ success: Bool) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }
    
    @IBAction private func successButtonAction(_ sender: Any) {
        self.buttonDidTap?(true)
        dismiss()
    }
    
    @IBAction private func cancelButtonAction(_ sender: Any) {
        self.buttonDidTap?(false)
        dismiss()
    }
    
    private func setupLocalization() {
        
        subtitleTitleLabel.text = Localizable.Waves.Dexcreateorder.Invalidpricepopup.subtitle
        placeOrderButton.setTitle(Localizable.Waves.Dexcreateorder.Invalidpricepopup.Button.placeOrder,
                                  for: .normal)
        
        buttonCancel.setTitle(Localizable.Waves.Dexcreateorder.Invalidpricepopup.Button.cancel,
                              for: .normal)
    }
    
    override func update(with model: Model) {
        
        if model.isPriceHigherMarket == true {
            titleLabel.text = Localizable.Waves.Dexcreateorder.Invalidpricepopup.Title.higherPrice(model.pricePercent)
        } else {
            titleLabel.text = Localizable.Waves.Dexcreateorder.Invalidpricepopup.Title.loverPrice(model.pricePercent)
        }
    }
}
