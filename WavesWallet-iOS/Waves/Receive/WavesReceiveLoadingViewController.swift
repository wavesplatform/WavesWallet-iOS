//
//  WavesReceiveAnimationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCode


class WavesReceiveLoadingViewController: UIViewController {

    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var viewAnimation: UIView!
    @IBOutlet weak var labelTitle: UILabel!
   
    @IBOutlet weak var iconArrowLogo: UIImageView!
    @IBOutlet weak var buttonCopyLink: UIButton!
    @IBOutlet weak var labelLink: UILabel!
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var butonCopy: UIButton!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var imageQrCode: UIImageView!

    @IBOutlet weak var viewLink: UIView!
    
    @IBOutlet weak var iconLogo: UIImageView!
    
    @IBOutlet weak var buttonCloseOffset: NSLayoutConstraint!
    
    
    var isWavesAddress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        butonCopy.tintColor = UIColor.submit400
        buttonShare.tintColor = UIColor.submit400

        scrollViewContent.alpha = 0
        buttonClose.alpha = 0

        if Platform.isIphone5 {
            imageBg.image = UIImage(named: "bg-iphone5")
        }
        else if Platform.isIphoneX {
            imageBg.image = UIImage(named: "bg-iphonex")
        }
        else if Platform.isIphonePlus {
            imageBg.image = UIImage(named: "bg-iphone8plus")
        }
        
        let qr = QRCode(WalletManager.getAddress())
        imageQrCode.image = qr?.image
        
        viewLink.isHidden = true
        if isWavesAddress {
            iconArrowLogo.isHidden = true
            iconLogo.image = UIImage(named: "logoWaves48")
            labelTitle.text = "Your Waves address"
            buttonCloseOffset.constant = 100
            viewLink.isHidden = false
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollViewContent.alpha = 1
                self.buttonClose.alpha = 1
                self.viewAnimation.alpha = 0
            })
        }
    }

    @IBAction func shareLinkTapped(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [labelLink.text!], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func copyLinkTapped(_ sender: Any) {
        UIPasteboard.general.string = labelLink.text

        buttonCopyLink.isUserInteractionEnabled = false
        buttonCopyLink.setImage(UIImage(named: "check_success"), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.buttonCopyLink.isUserInteractionEnabled = true
            self.buttonCopyLink.setImage(UIImage(named: "copy_address"), for: .normal)
        }
    }
    
    func dismiss() {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        navigationController?.popViewController(animated: true)
//
//        UIView.animate(withDuration: 0.3, animations: {
//            self.view.alpha = 0
//        }) { (complete) in
//            self.view.removeFromSuperview()
//            self.willMove(toParentViewController: nil)
//            self.removeFromParentViewController()
//        }
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = labelAddress.text
        
        butonCopy.isUserInteractionEnabled = false
        butonCopy.tintColor = UIColor.success400
        butonCopy.setTitleColor(UIColor.success400, for: .normal)
        butonCopy.setImage(UIImage(named: "check_success"), for: .normal)
        butonCopy.titleLabel?.text = "Сopied!"
        butonCopy.setTitle("Сopied!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.butonCopy.isUserInteractionEnabled = true
            self.butonCopy.tintColor = UIColor.submit400
            self.butonCopy.setTitleColor(UIColor.submit400, for: .normal)
            self.butonCopy.setImage(UIImage(named: "copy_address"), for: .normal)
            self.butonCopy.titleLabel?.text = "Copy"
            self.butonCopy.setTitle("Copy", for: .normal)
        }
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [labelAddress.text!], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss()
    }
    
    func showInController(_ inController: UIViewController) {
        
        inController.addChildViewController(self)
        didMove(toParentViewController: inController)
        inController.view.addSubview(view)
    }
}
