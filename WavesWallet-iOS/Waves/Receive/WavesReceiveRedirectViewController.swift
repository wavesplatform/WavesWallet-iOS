//
//  WavesReceiveRedirectViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/18/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol WavesReceiveRedirectViewControllerDelegate: class {
    
    func wavesReceiveRedirectViewControllerDidTapOkey()
}

class WavesReceiveRedirectViewController: UIViewController {

    var delegate: WavesReceiveRedirectViewControllerDelegate?
    
    @IBOutlet weak var imageBg: UIImageView!
   
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    var isCardMode = false
    var isBankMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)

        
        if Platform.isIphone5 {
            imageBg.image = UIImage(named: "bg-iphone5")
        }
        else if Platform.isIphoneX {
            imageBg.image = UIImage(named: "bg-iphonex")
        }
        else if Platform.isIphonePlus {
            imageBg.image = UIImage(named: "bg-iphone8plus")
        }
        
        if isCardMode {
            labelTitle.text = "You have been redirected to «Indacoin»"
            labelSubtitle.text = "After payment has been made your balance will be updated"
        }
        else if isBankMode {
            labelTitle.text = "You were redirected to the «IDNow» for verification"
            labelSubtitle.text = "After you go through the verification you will receive an email with further instructions"
        }
    }

    @IBAction func okeyTapped(_ sender: Any) {
        
        dismiss()
    }

    func dismiss() {

        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        
        if isCardMode {
            navigationController?.popViewController(animated: true)
        }
        else if isBankMode {
            delegate?.wavesReceiveRedirectViewControllerDidTapOkey()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }) { (complete) in
                self.view.removeFromSuperview()
                self.willMove(toParentViewController: nil)
                self.removeFromParentViewController()
            }
        }
    }
    
    
    func showInController(_ inController: UIViewController) {
        
        inController.addChildViewController(self)
        didMove(toParentViewController: inController)
        inController.view.addSubview(view)
    }
}
