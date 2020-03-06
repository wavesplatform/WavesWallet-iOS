//
//  ReceiveAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import QRCode
import RxSwift
import DataLayer
import Extensions

private enum Constants {
    static let copyDuration: TimeInterval = 2
}

final class ReceiveAddressViewController: UIViewController {
        
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
    
    private var disposeBag: DisposeBag = DisposeBag()

    var moduleInput: [ReceiveAddress.DTO.Info]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
//        setupInfo()
//        setupLocalization()
//        createCancelButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backgroundImage = UIImage()
        removeTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    private func createCancelButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarClosewhite.image, style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    @IBAction func closeTapped(_ sender: Any) {
        cancelTapped()
    }
    
    @objc private func cancelTapped() {
        if let assetVc = navigationController?.viewControllers.first(where: {$0.classForCoder == AssetDetailViewController.classForCoder()}) {
            navigationController?.popToViewController(assetVc, animated: true)
        }
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
//
//    private func setupLocalization() {
//        labelQRCode.text = Localizable.Waves.Receiveaddress.Label.yourQRCode
//        buttonClose.setTitle(Localizable.Waves.Receiveaddress.Button.close, for: .normal)
//        labelInvoiceLinkLocalized.text = Localizable.Waves.Receiveaddress.Label.linkToInvoice
//        buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copy, for: .normal)
//        buttonShare.setTitle(Localizable.Waves.Receiveaddress.Button.share, for: .normal)
//    }
    
    private func setupInfo() {
        
//        title = Localizable.Waves.Receiveaddress.Label.yourAddress(input.assetName)
//        labelAddress.text = input.address
//
//        AssetLogo.logo(icon: input.icon,
//                       style: .large)
//            .observeOn(MainScheduler.instance)
//            .bind(to: iconAsset.rx.image)
//            .disposed(by: disposeBag)
//
//        imageQR.image = QRCode(input.qrCode)?.image
//
//        if input.invoiceLink == nil {
//            viewInvoiceHeight.constant = 0
//        }
//        labelInvoiceLink.text = input.invoiceLink
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}



