//
//  DottedRoundView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

class DottedRoundView: UIView {
    @IBInspectable var lineColor: UIColor = UIColor.accent100 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    var isHiddenDottedLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var dottedCornerRadius: CGFloat = -1 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var perDashLength: CGFloat = 4.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var spaceBetweenDash: CGFloat = 4.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    override func draw(_ rect: CGRect) {
        guard !isHiddenDottedLine, let shapeLayer = layer as? CAShapeLayer else {
            return
        }
        
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineDashPattern = [perDashLength as NSNumber, spaceBetweenDash as NSNumber]
        shapeLayer.frame = rect
        shapeLayer.fillColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shapeLayer = layer as? CAShapeLayer
        shapeLayer?.path = UIBezierPath(rect: bounds).cgPath
    }
}
