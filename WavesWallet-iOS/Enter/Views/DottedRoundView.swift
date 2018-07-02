//
//  DottedRoundView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class DottedRoundView: UIView {

    let lineColorGray: UIColor = UIColor.accent100
    let lineColorBlue: UIColor = UIColor.submit400

    var isSelectedMode = false
    var isNotDraw = false
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: frame.size.width / 2)
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
