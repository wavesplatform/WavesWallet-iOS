//
//  GradientView.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 10/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QuartzCore

final class GradientView: UIView {

    enum Direction: Int {
        case vertical = 0
        case horizontal = 1

        var startPoint: CGPoint {
            switch self {
            case .horizontal:
                return CGPoint(x: 0, y: 0)

            case .vertical:
                return CGPoint(x: 0, y: 0)
                
            }
        }

        var endPoint: CGPoint {
            switch self {
            case .horizontal:
                return CGPoint(x: 1, y: 0)

            case .vertical:
                return CGPoint(x: 0, y: 1)
            }
        }

    }

    var direction: Direction = .vertical {
        didSet {
            updateColor()
        }
    }

    var directionValue: Int = 0 {
        didSet {
            direction = Direction(rawValue: directionValue) ?? .vertical
        }
    }

    var startColor: UIColor = .clear {
        didSet {
            updateColor()
        }
    }

    var endColor: UIColor = .clear {
        didSet {
            updateColor()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private func updateColor() {

        guard let layer = layer as? CAGradientLayer else { return }

        layer.startPoint = direction.startPoint
        layer.endPoint = direction.endPoint
        layer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
