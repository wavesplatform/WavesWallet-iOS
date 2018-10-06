//
//  DottedView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 05/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class DottedView: UIView {
    
    let lineColorGray: UIColor = UIColor.accent100
    let lineColorBlue: UIColor = UIColor.submit400
    
    var isSelectedMode = false
    var isNotDraw = false
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(rect: bounds)
        let dashes: [CGFloat] = [4, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        
        if isSelectedMode {
            path.lineWidth = 1.0
            lineColorBlue.setStroke()
            path.stroke()
        }
        else if !isNotDraw {
            path.lineWidth = 0.5
            lineColorGray.setStroke()
            path.stroke()
        }
    }
    
}
