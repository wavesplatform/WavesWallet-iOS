//
//  CALayer+RoundingCorners.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Constants {
    static let maskName = "calayer.mask.clip.name"
}

public extension CALayer {
    func clip() {
        mask = {
            let mask = CAShapeLayer()
            let path = UIBezierPath(rect: bounds)
            mask.frame = bounds
            mask.path = path.cgPath
            return mask
        }()
    }

    func clip(roundedRect rect: CGRect? = nil,
              byRoundingCorners corners: UIRectCorner = .allCorners,
              cornerRadius: CGFloat,
              inverse: Bool = false) {
        mask = {
            let roundedRect = rect ?? bounds

            let mask = CAShapeLayer()
            mask.name = Constants.maskName
            let path = UIBezierPath(roundedRect: roundedRect,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            if inverse {
                path.append(UIBezierPath(rect: bounds))
                mask.fillRule = CAShapeLayerFillRule.evenOdd
            }

            mask.frame = roundedRect
            mask.path = path.cgPath

            return mask
        }()
    }

    func removeClip() {
        mask = nil
    }

    func border(roundedRect rect: CGRect? = nil,
                byRoundingCorners corners: UIRectCorner = .allCorners,
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                borderColor: UIColor) {
        removeBorder()

        let rect = (rect ?? bounds)

        mask = {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: rect,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath

            return mask
        }()

        let border: CAShapeLayer = {
            let border = CAShapeLayer()

            let inset = borderWidth / 2
            let rect = rect.insetBy(dx: inset, dy: inset)

            border.strokeColor = borderColor.cgColor
            border.fillColor = UIColor.clear.cgColor
            border.lineWidth = borderWidth

            let cornerRadius = max(0, cornerRadius - inset)
            border.path = UIBezierPath(roundedRect: rect,
                                       byRoundingCorners: corners,
                                       cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            border.name = Constants.maskName
            return border
        }()

        addSublayer(border)
    }

    func removeBorder() {
        sublayers?
            .filter { $0.name == Constants.maskName }
            .forEach { $0.removeFromSuperlayer() }
    }
}
