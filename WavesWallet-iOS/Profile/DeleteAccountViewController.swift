//
//  DeleteAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class DeleteAccountViewController: UIViewController {

    
    var deleteBlock : (() -> Void)?
    var cancelBlock : (() -> Void)?
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
        
        viewContainer.addBounceStartAnimation()
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { (complete) in
            self.view.removeFromSuperview()
            self.willMove(toParentViewController: nil)
            self.removeFromParentViewController()
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        if let block = deleteBlock {
            block()
        }
        
        viewContainer.addBounceEndAnimation()
        dismiss()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        if let block = cancelBlock {
            block()
        }
        
        viewContainer.addBounceEndAnimation()
        dismiss()
    }
    
    func showInController(_ inController: UIViewController) {
        
        inController.addChildViewController(self)
        didMove(toParentViewController: inController)
        inController.view.addSubview(view)
    }
    
    deinit {
        print(self.classForCoder, #function)
    }
}
