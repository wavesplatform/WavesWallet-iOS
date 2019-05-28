//
//  UIView+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let smallNavBarHeight: CGFloat = 44
    static let bigNavBarHeight: CGFloat = 96
}


extension UIView {

  
    class func loadView() -> UIView {
        let clsName = String(describing: self)
        return Bundle.main.loadNibNamed(clsName, owner: nil, options: nil)!.last! as! UIView
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

    func setupSmallNavigationBar() {
        if #available(iOS 11.0, *) {
            firstAvailableViewController().navigationItem.prefersLargeTitles = false
        }
    }
    
    func setupBigNavigationBar() {
        if #available(iOS 11.0, *) {
            firstAvailableViewController().navigationItem.prefersLargeTitles = true
            firstAvailableViewController().navigationItem.largeTitleDisplayMode = .automatic
        }
    }

    
    func createTopCorners(radius: CGFloat) {
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = shadowPath.cgPath
        layer.mask = maskLayer
    }
    
   
}
