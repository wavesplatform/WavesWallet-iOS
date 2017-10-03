//
//  OrderConfirmView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 01.09.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

protocol OrderConfirmViewDelegate: class {
    
    func orderConfirmViewDidConfirm()
}

class OrderConfirmView: UIView {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var checkMarkIcon: UIImageView!
  
    var delegate: OrderConfirmViewDelegate?
    var orderType: OrderType!
    
    var isCheking : Bool = false
    
    override func awakeFromNib() {
        viewBg.layer.cornerRadius = 5
     
        self.alpha = 0
        
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 1
        }
        
        addBounceStartAnimation(viewBg)
    }
    
    class func needShow() -> Bool {
        
        return !UserDefaults.standard.bool(forKey: "noNeedAsk")
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        addBounceEndAnimation(viewBg)
        dismissView()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        addBounceEndAnimation(viewBg)
        dismissView()
        delegate?.orderConfirmViewDidConfirm()
        
        if isCheking {
            UserDefaults.standard.set(true, forKey: "noNeedAsk")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func checkMarkTapped(_ sender: Any) {
    
        isCheking = !isCheking
        
        if isCheking {
            checkMarkIcon.image = UIImage(named: "checkmark_fill")
        }
        else {
            checkMarkIcon.image = UIImage(named: "checkmark_empty")
        }
    }
    
    class func show() -> OrderConfirmView {
        let view  = Bundle.main.loadNibNamed("OrderConfirmView", owner: nil, options: nil)?.first as! OrderConfirmView
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.addSubview(view)
        view.frame = delegate.window!.bounds
        return view
    }
    
    func dismissView() {
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.alpha = 0
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
    
    func addBounceStartAnimation (_ view: UIView) {
        
        view.alpha = 0
        
        UIView.animate(withDuration: 0.1) {
            view.alpha = 1
        }
        
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        
        let bounceAnimation = CAKeyframeAnimation.init(keyPath: "transform.scale")
        bounceAnimation.values = [0.5, 1.2, 0.9, 1.0]
        bounceAnimation.duration = 0.4
        bounceAnimation.isRemovedOnCompletion = false
        view.layer.add(bounceAnimation, forKey: "bounce")
        view.layer.transform = CATransform3DIdentity
    }
    
    func addBounceEndAnimation(_ view: UIView) {
        
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        
        let bounceAnimation = CAKeyframeAnimation.init(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 0.5, 0.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.isRemovedOnCompletion = false
        view.layer.add(bounceAnimation, forKey: "bounce")
        view.layer.transform = CATransform3DIdentity
    }

}
