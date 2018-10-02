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

    override func draw(_ rect: CGRect) {

        guard isHiddenDottedLine == false else {
            return
        }
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: frame.size.width / 2)
        let dashes: [CGFloat] = [4, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        path.lineWidth = lineWidth
        lineColor.setStroke()
        path.stroke()
    }
}
