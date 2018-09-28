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
        
        viewBg.addBounceStartAnimation()
    }
    
    class func needShow() -> Bool {
        
        return !UserDefaults.standard.bool(forKey: "noNeedAsk")
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        viewBg.addBounceEndAnimation()
        dismissView()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        viewBg.addBounceEndAnimation()
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

}
