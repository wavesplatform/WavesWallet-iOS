//
//  UIView+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    private enum Constant {
        static let defaultShadowColor = UIColor.black.withAlphaComponent(0.08)
        static let defaultShadowOffset = CGSize(width: 0, height: 3)
        static let defaultShadowOpacity: Float = 0.7
        static let defaultShadowRadius: Float = 3.5
        static let defaultShadowRasterize = true
    }
    
    func setupDefaultShadows() {
        let shadowOptions = ShadowOptions(offset: Constant.defaultShadowOffset,
                                          color: Constant.defaultShadowColor,
                                          opacity: Constant.defaultShadowOpacity,
                                          shadowRadius: Constant.defaultShadowRadius,
                                          shouldRasterize: Constant.defaultShadowRasterize)
        setupShadow(options: shadowOptions)
    }
    
    func addAssetPairIconShadow() {
        layer.setupShadow(options: .init(offset: .init(width: 0, height: 3),
                                         color: .black,
                                         opacity: 0.2,
                                         shadowRadius: 3,
                                         shouldRasterize: false))
        clipsToBounds = false
    }
    
    func addTableCellShadowStyle(offset: CGSize = CGSize(width: 0, height: 4)) {

        setupShadow(options: .init(offset: offset,
                                   color: .black,
                                   opacity: 0.10,
                                   shadowRadius: 2,
                                   shouldRasterize: true))
        self.cornerRadius = 4
    }
    
    func removeTableCellShadowStyle() {
        removeShadow()
    }
    
    class func loadView<View>() -> View where View : UIView {
        let clsName = String(describing: self)
        return Bundle.main.loadNibNamed(clsName, owner: nil, options: nil)!.last! as! View
    }
    
    func shakeView() {
        let anim = CAKeyframeAnimation.init(keyPath: "transform")
        anim.values = [NSValue.init(caTransform3D: CATransform3DMakeTranslation(-7.0, 0.0, 0.0)),
                       NSValue.init(caTransform3D:CATransform3DMakeTranslation(7.0, 0.0, 0.0))]
        anim.autoreverses = true
        anim.repeatCount = 2.0
        anim.duration = 0.07
        layer.add(anim, forKey: nil)
    }
    
    
    func addBounceStartAnimation() {
    
        alpha = 0;
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
        
        layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
    
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [0.5, 1.2, 0.9, 1.0]
        bounceAnimation.duration = 0.4
        bounceAnimation.isRemovedOnCompletion = false
        layer.add(bounceAnimation, forKey: "bounce")
        layer.transform = CATransform3DIdentity
    }
    
    func addBounceEndAnimation() {
        layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
    
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 0.5, 0.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.isRemovedOnCompletion = false
        layer.add(bounceAnimation, forKey: "bounce")
        layer.transform = CATransform3DIdentity
    }

    func firstAvailableViewController() -> UIViewController {
        
        if let nextResponder = next {
            if let controller = nextResponder as? UIViewController {
                return controller
            }
            else if let view = nextResponder as? UIView {
                return view.firstAvailableViewController()
            }
        }
        return UIViewController()
    }

    func setupButtonActiveState() {
        backgroundColor = .submit400
        isUserInteractionEnabled = true
    }
   
    func setupButtonDeactivateState() {
        isUserInteractionEnabled = false
        backgroundColor = .submit200
    }
    
    func createTopCorners(radius: CGFloat) {
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = shadowPath.cgPath
        layer.mask = maskLayer
    }
}
