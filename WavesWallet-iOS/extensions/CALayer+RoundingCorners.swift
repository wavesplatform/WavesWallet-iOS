//
//  CALayer+RoundingCorners.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let maskName = "calayer.mask.name"
}

extension CALayer {

    func clip() {

        self.mask = {
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

        self.mask = {
            let mask = CAShapeLayer()
            let path = UIBezierPath(roundedRect: rect ?? bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            if inverse {
                path.append(UIBezierPath(rect: bounds))
                mask.fillRule = kCAFillRuleEvenOdd
            }

            mask.frame = bounds
            mask.path = path.cgPath

            mask.shadowColor = self.shadowColor
            mask.shadowOffset = self.shadowOffset
            mask.shadowOpacity = self.shadowOpacity
            mask.shadowRadius = self.shadowRadius
            mask.shadowPath = self.shadowPath
            mask.shouldRasterize = self.shouldRasterize
            mask.rasterizationScale = self.rasterizationScale

            return mask
        }()
    }

    func removeClip() {
        self.mask = nil
    }

    func border(roundedRect rect: CGRect? = nil,
                byRoundingCorners corners: UIRectCorner = .allCorners,
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                borderColor: UIColor) {

        self.removeBorder()

        let rect = (rect ?? bounds)

        self.mask = {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: rect,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            mask.shadowColor = self.shadowColor
            mask.shadowOffset = self.shadowOffset
            mask.shadowOpacity = self.shadowOpacity
            mask.shadowRadius = self.shadowRadius
            mask.shadowPath = self.shadowPath


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
        self.sublayers?
            .filter { $0.name == Constants.maskName }
            .forEach { $0.removeFromSuperlayer() }
    }
}
