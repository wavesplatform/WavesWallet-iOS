//
//  BorderButtView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class BorderButtView: UIView {
    
    override func draw(_ rect: CGRect) {

        let path = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 0.5, width: frame.size.width - 1, height: frame.size.height - 1), cornerRadius: 3)
        path.lineWidth = 0.5
        let dashes: [CGFloat] = [6, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        UIColor.basic300.setStroke()
        path.stroke()
    }
}
