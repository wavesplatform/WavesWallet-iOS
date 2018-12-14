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

    struct Settings {
        let startPoint: CGPoint
        let endPoint: CGPoint
        let locations: [Float]?
    }

    enum Direction {
        case vertical
        case horizontal
        case custom(Settings)

        var startPoint: CGPoint {
            switch self {
            case .custom(let settings):
                return settings.startPoint
            default:
                return CGPoint(x: 0, y: 0)
            }
        }

        var endPoint: CGPoint {
            switch self {
            case .horizontal:
                return CGPoint(x: 1, y: 0)

            case .vertical:
                return CGPoint(x: 0, y: 1)

            case .custom(let settings):
                return settings.endPoint
            }
        }

        var locations: [Float]? {
            switch self {
            case .custom(let settings):
                return settings.locations
            default:
                return nil
            }
        }
    }

    var direction: Direction = .vertical {
        didSet {
            updateColor()
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
        layer.locations = direction.locations?.map({ (value) -> NSNumber in
            return NSNumber.init(value: value)
        })
        layer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
