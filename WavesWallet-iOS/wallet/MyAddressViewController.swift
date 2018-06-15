//
//  MyAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCode

class MyAddressViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    var lastScrollCorrectOffset: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Your address"
        createBackButton()
        hideTopBarLine()
        buttonCopy.tintColor = UIColor.submit400
        buttonShare.tintColor = UIColor.submit400

        let qr = QRCode.init(WalletManager.getAddress())
        qrCodeImageView.image = qr?.image
        labelAddress.text = WalletManager.getAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastScrollCorrectOffset = nil
    }
  
    func setupLastScrollCorrectOffset() {
        lastScrollCorrectOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
            scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
        }
        
        setupTopBarLine()
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        
        UIPasteboard.general.string = labelAddress.text
        
        buttonCopy.isUserInteractionEnabled = false
        buttonCopy.tintColor = UIColor.success400
        buttonCopy.setTitleColor(UIColor.success400, for: .normal)
        buttonCopy.setImage(UIImage(named: "check_success"), for: .normal)
        buttonCopy.titleLabel?.text = "Сopied!"
        buttonCopy.setTitle("Сopied!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.buttonCopy.isUserInteractionEnabled = true
            self.buttonCopy.tintColor = UIColor.submit400
            self.buttonCopy.setTitleColor(UIColor.submit400, for: .normal)
            self.buttonCopy.setImage(UIImage(named: "copy_address"), for: .normal)
            self.buttonCopy.titleLabel?.text = "Copy"
            self.buttonCopy.setTitle("Copy", for: .normal)
        }
    }

    
    @IBAction func shareTapped(_ sender: Any) {
    
        let activityVC = UIActivityViewController(activityItems: [labelAddress.text!], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
