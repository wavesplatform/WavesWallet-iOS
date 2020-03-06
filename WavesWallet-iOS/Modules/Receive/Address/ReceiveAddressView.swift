//
//  ReceiveAddressView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class ReceiveAddressView: UIView, NibOwnerLoadable {
                
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
    }
}

// MARK: Private
private extension ReceiveAddress {
    
//     @IBAction private func copyTapped(_ sender: Any) {
//
//         UIPasteboard.general.string = labelAddress.text
//
//         buttonCopy.isUserInteractionEnabled = false
//         buttonCopy.tintColor = UIColor.success400
//         buttonCopy.setTitleColor(UIColor.success400, for: .normal)
//         buttonCopy.setImage(Images.checkSuccess.image, for: .normal)
//         buttonCopy.titleLabel?.text = Localizable.Waves.Receiveaddress.Button.copied
//         buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copied, for: .normal)
//
//         DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDuration) {
//             self.buttonCopy.isUserInteractionEnabled = true
//             self.buttonCopy.tintColor = UIColor.submit400
//             self.buttonCopy.setTitleColor(UIColor.submit400, for: .normal)
//             self.buttonCopy.setImage(Images.copyAddress.image, for: .normal)
//             self.buttonCopy.titleLabel?.text = Localizable.Waves.Receiveaddress.Button.copy
//             self.buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copy, for: .normal)
//         }
//     }
//
//     @IBAction func copyInvoiceLink(_ sender: Any) {
//         UIPasteboard.general.string = labelInvoiceLink.text
//
//         buttonCopyInvoiceLink.isUserInteractionEnabled = false
//         buttonCopyInvoiceLink.tintColor = UIColor.success400
//         buttonCopyInvoiceLink.setImage(Images.checkSuccess.image, for: .normal)
//
//         DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDuration) {
//             self.buttonCopyInvoiceLink.isUserInteractionEnabled = true
//             self.buttonCopyInvoiceLink.tintColor = UIColor.submit400
//             self.buttonCopyInvoiceLink.setImage(Images.copyAddress.image, for: .normal)
//         }
//     }
//
//     @IBAction private func shareTapped(_ sender: Any) {
//
//         guard let text = labelAddress.text else { return }
//         let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
//         present(activityVC, animated: true, completion: nil)
//
//     }
//
//     @IBAction func shareInvoiceLink(_ sender: Any) {
//         guard let text = labelInvoiceLink.text else { return }
//         let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
//         present(activityVC, animated: true, completion: nil)
//     }
 
    
//    private func setupLocalization() {
//        labelQRCode.text = Localizable.Waves.Receiveaddress.Label.yourQRCode
//        buttonClose.setTitle(Localizable.Waves.Receiveaddress.Button.close, for: .normal)
//        labelInvoiceLinkLocalized.text = Localizable.Waves.Receiveaddress.Label.linkToInvoice
//        buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copy, for: .normal)
//        buttonShare.setTitle(Localizable.Waves.Receiveaddress.Button.share, for: .normal)
//    }
}

// MARK: ViewConfiguration

extension ReceiveAddressView: ViewConfiguration {
    
    func update(with model: ReceiveAddress.DTO.Info) {
        
    }
}
