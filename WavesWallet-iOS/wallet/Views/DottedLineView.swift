//
//  DotLineView.swift
//  DotLineView
//
//  Created by Kenji Abe on 2016/06/28.
//  Copyright © 2016年 Kenji Abe. All rights reserved.
//

import UIKit

@IBDesignable
public class DottedLineView: UIView {
    
    @IBInspectable
    public var lineColor: UIColor = UIColor.black
    
    @IBInspectable
    public var lineWidth: CGFloat = CGFloat(4)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initBackgroundColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initBackgroundColor()
    }
    
    override public func prepareForInterfaceBuilder() {
        initBackgroundColor()
    }
    
    public override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        configurePath(path: path, rect: rect)
        lineColor.setStroke()
        path.stroke()
    }
    
    func initBackgroundColor() {
        if backgroundColor == nil {
            backgroundColor = UIColor.clear
        }
    }
    
    private func configurePath(path: UIBezierPath, rect: CGRect) {

        let center = rect.height * 0.5
//        let drawWidth = rect.size.width - (rect.size.width.truncatingRemainder(dividingBy: (lineWidth * 2))) + lineWidth
        let drawWidth = rect.size.width

        let startPositionX : CGFloat = 0
//        let startPositionX : CGFloat = 0//(rect.size.width - drawWidth) * 0.5 + lineWidth

        path.move(to: CGPoint(x: startPositionX, y: center))
        path.addLine(to: CGPoint(x: drawWidth, y: center))
        
        let dashes: [CGFloat] = [lineWidth, lineWidth / 2]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
    }
    
}
