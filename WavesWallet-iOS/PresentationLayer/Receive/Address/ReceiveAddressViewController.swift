//
//  ReceiveAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher
import QRCode

private enum Constants {
    static let icon = CGSize(width: 48, height: 48)
    static let copyDuration: TimeInterval = 2
}

final class ReceiveAddressViewController: UIViewController {

    var input: ReceiveAddressModuleBuilder.Input!
    
    @IBOutlet private weak var buttonShare: UIButton!
    @IBOutlet private weak var buttonCopy: UIButton!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconAsset: UIImageView!
    @IBOutlet private weak var imageQR: UIImageView!
    @IBOutlet private weak var labelQRCode: UILabel!
    @IBOutlet private weak var buttonCopyInvoiceLink: UIButton!
    @IBOutlet private weak var labelInvoiceLink: UILabel!
    @IBOutlet private weak var labelInvoiceLinkLocalized: UILabel!
    @IBOutlet private weak var viewInvoice: UIView!
    @IBOutlet private weak var viewInvoiceHeight: NSLayoutConstraint!
    @IBOutlet private weak var buttonClose: UIButton!
    private var logoTask: RetrieveImageDiskTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        setupInfo()
        setupLocalization()
        addBgBlueImage()
        createCancelButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backgroundImage = UIImage()
        hideTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    private func createCancelButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarClosewhite.image, style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    @IBAction func closeTapped(_ sender: Any) {
        cancelTapped()
    }
    
    @objc private func cancelTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupLocalization() {
        labelQRCode.text = Localizable.ReceiveAddress.Label.yourQRCode
        buttonClose.setTitle(Localizable.ReceiveAddress.Button.close, for: .normal)
        labelInvoiceLinkLocalized.text = Localizable.ReceiveAddress.Label.linkToInvoice
    }
    
    private func setupInfo() {
        title = Localizable.ReceiveAddress.Label.yourAddress(input.assetName)
        labelAddress.text = input.address
        let iconStyle = AssetLogo.Style(size: Constants.icon, font: UIFont.systemFont(ofSize: 22), border: nil)
        logoTask = AssetLogo.logoFromCache(name: input.icon, style: iconStyle, completionHandler: { [weak self] (image) in
            self?.iconAsset.image = image
        })
        imageQR.image = QRCode(input.qrCode)?.image
        
        if input.invoiceLink == nil {
            viewInvoiceHeight.constant = 0
        }
        labelInvoiceLink.text = input.invoiceLink
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func copyTapped(_ sender: Any) {
        
        UIPasteboard.general.string = labelAddress.text

        buttonCopy.isUserInteractionEnabled = false
        buttonCopy.tintColor = UIColor.success400
        buttonCopy.setTitleColor(UIColor.success400, for: .normal)
        buttonCopy.setImage(Images.checkSuccess.image, for: .normal)
        buttonCopy.titleLabel?.text = Localizable.ReceiveAddress.Button.copied
        buttonCopy.setTitle(Localizable.ReceiveAddress.Button.copied, for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDuration) {
            self.buttonCopy.isUserInteractionEnabled = true
            self.buttonCopy.tintColor = UIColor.submit400
            self.buttonCopy.setTitleColor(UIColor.submit400, for: .normal)
            self.buttonCopy.setImage(Images.copyAddress.image, for: .normal)
            self.buttonCopy.titleLabel?.text = Localizable.ReceiveAddress.Button.copy
            self.buttonCopy.setTitle(Localizable.ReceiveAddress.Button.copy, for: .normal)
        }
    }
   
    @IBAction func copyInvoiceLink(_ sender: Any) {
        UIPasteboard.general.string = labelInvoiceLink.text
        
        buttonCopyInvoiceLink.isUserInteractionEnabled = false
        buttonCopyInvoiceLink.tintColor = UIColor.success400
        buttonCopyInvoiceLink.setImage(Images.checkSuccess.image, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDuration) {
            self.buttonCopyInvoiceLink.isUserInteractionEnabled = true
            self.buttonCopyInvoiceLink.tintColor = UIColor.submit400
            self.buttonCopyInvoiceLink.setImage(Images.copyAddress.image, for: .normal)
        }
    }
    
    @IBAction private func shareTapped(_ sender: Any) {
        
        guard let text = labelAddress.text else { return }
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)

    }
    
    @IBAction func shareInvoiceLink(_ sender: Any) {
        guard let text = labelInvoiceLink.text else { return }
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
