//
//  SeparatorView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

enum SeparatorLineStyle: Int {
    case horizontal = 0
    case vertical = 1
}

fileprivate final class SeparatorLineView: UIView {

    override class var layerClass: AnyClass {
        get {
            return CAShapeLayer.self
        }
    }

    private var lineSize: CGFloat {
        return 1.0 / UIScreen.main.scale
    }

    var style: SeparatorLineStyle = .horizontal {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    var isDashed: Bool = false {
        didSet {
            let layer: CAShapeLayer = self.layer as! CAShapeLayer
            if isDashed {
                layer.lineDashPattern = dashPattern.map { NSNumber(value: $0) }
                layer.lineDashPhase = dashPhase
            } else {
                layer.lineDashPhase = 0
                layer.lineDashPattern = []
            }
        }
    }

    var dashPhase: CGFloat = 0 {
        didSet {
            let layer: CAShapeLayer = self.layer as! CAShapeLayer
            layer.lineDashPhase = dashPhase
            setNeedsDisplay()
        }
    }

    var dashPattern: [Int] = [] {
        didSet {
            let layer: CAShapeLayer = self.layer as! CAShapeLayer
            layer.lineDashPattern = dashPattern.map { NSNumber(value: $0) }
            setNeedsDisplay()
        }
    }

    var lineColor: UIColor? {
        didSet {
            let layer: CAShapeLayer = self.layer as! CAShapeLayer
            layer.strokeColor = lineColor?.cgColor ?? UIColor.black.cgColor
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSettings()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSettings()
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        let path = CGMutablePath()

        switch style {
        case .horizontal:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: frame.width, y: 0))
        case .vertical:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: frame.height))
        }

        let layer: CAShapeLayer = self.layer as! CAShapeLayer
        layer.path = path
        layer.strokeStart = 0
    }

    private func initialSettings() {
        let layer: CAShapeLayer = self.layer as! CAShapeLayer
        layer.lineWidth = lineSize
    }
}

final class SeparatorView: UIView {

    private lazy var lineView = SeparatorLineView()

    private var lineSize: CGFloat {
        return 1.0 / UIScreen.main.scale
    }

    var style: SeparatorLineStyle = .horizontal {
        didSet {
            lineView.style = style
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var styleInt: Int = 0 {
        didSet {
            style = SeparatorLineStyle(rawValue: styleInt) ?? .horizontal
        }
    }

    @IBInspectable var isDashed: Bool = false {
        didSet {
            lineView.isDashed = isDashed
        }
    }

    @IBInspectable var dashPattern: String = "" {
        didSet {
            lineView.dashPattern = dashPattern.components(separatedBy: ",").map { Int($0) ?? 0 }
        }
    }
    @IBInspectable var dashPhase: CGFloat = 0 {
        didSet {
            lineView.dashPhase = dashPhase
        }
    }

    @IBInspectable var lineColor: UIColor? {
        didSet {
            lineView.lineColor = lineColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSettings()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSettings()
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        switch style {
        case .horizontal:
            size.height = lineSize
        case .vertical:
            size.width = lineSize
        }
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch style {
        case .horizontal:
            lineView.frame = CGRect(x: 0, y: bounds.height - lineSize, width: bounds.width, height: lineSize)
        case .vertical:
            lineView.frame = CGRect(x: 0, y: 0, width: lineSize, height: bounds.height)
        }
    }

    private func initialSettings() {
        addSubview(lineView)
        backgroundColor = .clear
    }
}
