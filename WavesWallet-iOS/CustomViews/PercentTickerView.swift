//
//  PercentTicker.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 28.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let cornerRadius: Float = 3
    static let backgroundAlpha: CGFloat = 0.1
}

final class PercentTickerView: UIView {

    private var label: UILabel!
    private var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        backgroundColor = .clear
        
        background = .init(frame: bounds)
        background.alpha = Constants.backgroundAlpha
        addSubview(background)
        
        label = .init(frame: bounds)
        label.textAlignment = .center
        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        background.frame = bounds
    }
}

extension PercentTickerView: ViewConfiguration {
    
    struct Model {
        let firstPrice: Double
        let lastPrice: Double
        let fontSize: CGFloat
    }
    
    func update(with model: Model) {
        
        label.font = UIFont.systemFont(ofSize: model.fontSize)
        
        var deltaPercent: Double {
            if model.firstPrice > model.lastPrice {
                return (model.firstPrice - model.lastPrice) * 100
            }
            return (model.lastPrice - model.firstPrice) * 100
        }
           
        let percent = model.firstPrice != 0 ? deltaPercent / model.firstPrice : 0
        
        if model.lastPrice > model.firstPrice {
            label.textColor = .success500
            label.text = String(format: "+%.02f", percent) + "%"
            background.backgroundColor = .success500
        }
        else if model.firstPrice > model.lastPrice {
            label.textColor = .error500
            label.text = String(format: "%.02f", percent * -1) + "%"
            background.backgroundColor = .error500
        }
        else {
            label.textColor = .basic500
            label.text = String(format: "%.02f", percent) + "%"
            background.backgroundColor = .basic500
        }
    }
}
