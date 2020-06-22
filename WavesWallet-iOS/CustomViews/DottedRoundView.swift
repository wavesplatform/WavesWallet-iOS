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

    override func draw(_: CGRect) {
        guard isHiddenDottedLine == false else {
            return
        }

        let cornerRadius = dottedCornerRadius == -1 ? frame.size.width / 2 : dottedCornerRadius
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
