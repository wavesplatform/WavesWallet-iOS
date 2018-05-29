//
//  TransactionCommentView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionCommentView: UIView {

    @IBOutlet weak var labelComment: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        frame.origin.x = 16
        frame.size.width = Platform.ScreenWidth - 32
        layer.cornerRadius = 5.0
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        path.lineWidth = 1
        let dashes: [CGFloat] = [4, 3]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        UIColor.basic300.setStroke()
        path.stroke()
    }
    
    func setup(comment: String) {
        labelComment.text = comment
        let height = comment.maxHeight(font: labelComment.font, forWidth: frame.size.width - 24)
        frame.size.height = height + 24
    
        setNeedsDisplay()
    }
}
