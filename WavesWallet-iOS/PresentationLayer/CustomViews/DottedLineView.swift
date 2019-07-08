//
//  DotLineView.swift
//  DotLineView
//
//

import UIKit

@IBDesignable
//TODO: May be merging DottedLineView with SeparatorLine
public class DottedLineView: UIView {
    
    let lineColor: UIColor = UIColor.accent100
    let lineWidth: CGFloat = CGFloat(6)
    
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
        path.lineWidth = 0.5
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

        let drawWidth = rect.size.width

        let startPositionX : CGFloat = 0

        path.move(to: CGPoint(x: startPositionX, y: 0))
        path.addLine(to: CGPoint(x: drawWidth, y: 0))
        
        let dashes: [CGFloat] = [lineWidth, lineWidth / 2]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
    }
    
}
