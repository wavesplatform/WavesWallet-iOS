//
//  DexChartCandlePriceView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let additionalDeltaWidth: CGFloat = 7
    static let cornerRadius: CGFloat = 2
}

final class DexChartCandlePriceView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var viewLine: UIView!
    @IBOutlet weak var viewBgPrice: UIView!
    @IBOutlet weak var viewPriceWidth: NSLayoutConstraint!
    
    private var shapeLayer: CAShapeLayer?
    private var isNeedUpdateConstraints = false
    private var width: CGFloat = 0

    var highlightedMode = false {
        didSet {
            viewLine.isHidden = highlightedMode
            
            if !highlightedMode && shapeLayer != nil {
                shapeLayer?.removeFromSuperlayer()
                shapeLayer = nil
            }
        }
    }
    
    override func updateConstraints() {
        if isNeedUpdateConstraints {
            isNeedUpdateConstraints = false
            viewPriceWidth.constant = width
            viewBgPrice.layer.cornerRadius = Constants.cornerRadius
        }
        
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setupWidth(candles: [DexChart.DTO.Candle], pair: DexTraderContainer.DTO.Pair) {
        if width == 0 {
            width = DexChartHelper.candleRightWidth(candles: candles, pair: pair) + Constants.additionalDeltaWidth
            isNeedUpdateConstraints = true
            setNeedsUpdateConstraints()
        }
    }
    
    func setup(price: Double, color: UIColor, pair: DexTraderContainer.DTO.Pair) {
   
        let numberFormatter = DexChart.ViewModel.numberFormatter(pair: pair)

        labelPrice.text = numberFormatter.string(from: NSNumber(value: price))
        viewBgPrice.backgroundColor = color
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
