//
//  DottedRoundView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class DottedRoundView: UIView {

    var lineColor: UIColor = UIColor.accent100 {
        didSet {
            setNeedsDisplay()
        }
    }

    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }

    var isHiddenDottedLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var dottedCornerRadius: CGFloat = -1

    override func draw(_ rect: CGRect) {

        guard isHiddenDottedLine == false else {
            return
        }

        let cornerRadius = self.dottedCornerRadius == -1 ? frame.size.width / 2 : self.dottedCornerRadius
        let drawPath = CGRect(x: lineWidth / 2,
                              y: lineWidth / 2,
                              width: bounds.size.width - lineWidth,
                              height: bounds.size.height - lineWidth)
        let path = UIBezierPath(roundedRect: drawPath, cornerRadius: cornerRadius)
        let dashes: [CGFloat] = [4, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        path.lineWidth = lineWidth
        lineColor.setStroke()
        path.stroke()
    }
}
