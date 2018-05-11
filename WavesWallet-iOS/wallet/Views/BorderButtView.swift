//
//  BorderButtView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class BorderButtView: UIView {

    let lineColor: UIColor = UIColor.basic300

    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 3)
        path.lineWidth = 1
        let dashes: [CGFloat] = [6, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        lineColor.setStroke()
        path.stroke()
    }
    
}
