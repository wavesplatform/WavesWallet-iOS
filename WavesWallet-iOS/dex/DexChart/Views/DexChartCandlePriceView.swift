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
    @IBOutlet private weak var viewLine: UIView!
    
    private var shapeLayer: CAShapeLayer?
    
    var highlightedMode = false {
        didSet {
            viewLine.isHidden = highlightedMode
            
            if !highlightedMode && shapeLayer != nil {
                shapeLayer?.removeFromSuperlayer()
                shapeLayer = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setup(price: Double, color: UIColor) {
        
        labelPrice.text = String(format: "%0.6f", price)
        labelPrice.backgroundColor = color
        viewLine.backgroundColor = color
        
        if highlightedMode && shapeLayer == nil {
            
            let lineDashPattern = DexChart.ChartContants.Candle.DataSet.highlightLineDashLengths.map { NSNumber(value: Float($0)) }
            
            shapeLayer = CAShapeLayer()
            guard let shapeLayer = shapeLayer else { return }
            
            shapeLayer.strokeColor = DexChart.ChartContants.Candle.DataSet.highlightColor.cgColor
            shapeLayer.lineWidth = DexChart.ChartContants.Candle.DataSet.highlightLineWidth
            shapeLayer.lineDashPattern = lineDashPattern
            
            let y = frame.size.height / 2
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 0, y: y),
                                    CGPoint(x: frame.size.width - labelPrice.frame.size.width, y: y)])
            shapeLayer.path = path
            layer.addSublayer(shapeLayer)
        }
        
    }
}
