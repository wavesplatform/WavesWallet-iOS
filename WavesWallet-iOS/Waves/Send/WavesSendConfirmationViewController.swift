//
//  WavesSendConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesSendConfirmationViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var labelTitleBig: UILabel!
    @IBOutlet weak var labelTitleSmall: UILabel!
    @IBOutlet weak var iconState: UIImageView!
    @IBOutlet weak var labelValue: UILabel!
    
    @IBOutlet weak var viewSpam: UIView!
    @IBOutlet weak var viewAssetType: UIView!
    
    @IBOutlet weak var textFieldDescription: UITextField!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var viewAnimation: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewFinish: UIView!
    @IBOutlet weak var labelDescriptionError: UILabel!
    
    let maxDescriptionLength = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        labelTitleSmall.isHidden = true

        viewSpam.isHidden = true
        if arc4random() % 3 == 0 {
            viewSpam.isHidden = false
            viewAssetType.isHidden = true
        }
        
        textFieldDescription.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupButtonConfirm()
        viewAnimation.alpha = 0
        viewFinish.alpha = 0
        labelDescriptionError.isHidden = true
    }
    
    func setupButtonConfirm() {
        if textFieldDescription.text!.count > 0 && textFieldDescription.text!.count <= maxDescriptionLength {
            buttonConfirm.isUserInteractionEnabled = true
            buttonConfirm.backgroundColor = .submit400
        }
        else {
            buttonConfirm.isUserInteractionEnabled = false
            buttonConfirm.backgroundColor = .submit200
        }
    }
    
    func textFieldDidChange() {
        setupButtonConfirm()
        
        labelDescriptionError.isHidden = true
        if textFieldDescription.text!.count > maxDescriptionLength {
            labelDescriptionError.isHidden = false
        }
    }
    
    @IBAction func okeyTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        
        textFieldDescription.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.alpha = 0
            self.viewTop.alpha = 0
            self.viewAnimation.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.viewAnimation.alpha = 0
                self.viewFinish.alpha = 1
            })
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showSmallTitle = scrollView.contentOffset.y >= 30
        
        if showSmallTitle {
            labelTitleBig.isHidden = true
            labelTitleSmall.isHidden = false
        }
        else {
            labelTitleBig.isHidden = false
            labelTitleSmall.isHidden = true
        }
    }
    
}
