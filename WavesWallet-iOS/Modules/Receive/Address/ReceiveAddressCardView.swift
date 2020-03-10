//
//  ReceiveAddressView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import QRCode
import RxSwift

private enum Constants {
    static let copyDuration: TimeInterval = 2
    static let widthIcon: CGFloat = 90
    static let topInfoQRCodePadding: CGFloat = 8
    static let bottomInfoQRCodePadding: CGFloat = 8
    static let topAssetIconPaddin: CGFloat = 16
    static let bottomAssetIconPadding: CGFloat = 16
}

final class ReceiveAddressCardView: UIView, NibLoadable {
                
    @IBOutlet private weak var buttonShare: UIButton!
    @IBOutlet private weak var buttonCopy: UIButton!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var labelQRCode: UILabel!
    @IBOutlet private weak var iconAsset: UIImageView!
    @IBOutlet private weak var imageQR: UIImageView!
    @IBOutlet private weak var widthIconLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topInfoQRCodeLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topQRCodeLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var topAssetIconLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomAssetIconLayoutConstraint: NSLayoutConstraint!
    
    private let disposeBag: DisposeBag = DisposeBag()
    private var model: ReceiveAddress.DTO.Info? = nil
    
    var shareTapped: ((ReceiveAddress.DTO.Info) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Platform.isIphone5 {
            widthIconLayoutConstraint.constant = Constants.widthIcon
            topInfoQRCodeLayoutConstraint.constant = Constants.topInfoQRCodePadding
            topQRCodeLayoutConstraint.constant = Constants.bottomInfoQRCodePadding
            topAssetIconLayoutConstraint.constant = Constants.topAssetIconPaddin
            bottomAssetIconLayoutConstraint.constant = Constants.bottomAssetIconPadding
        }
    }
}

// MARK: Private

private extension ReceiveAddressCardView {
    
     @IBAction private func copyTapped(_ sender: Any) {

         UIPasteboard.general.string = labelAddress.text
        
         buttonCopy.isUserInteractionEnabled = false
         buttonCopy.tintColor = UIColor.success400
         buttonCopy.setTitleColor(UIColor.success400, for: .normal)
         buttonCopy.setImage(Images.checkSuccess.image, for: .normal)
         buttonCopy.titleLabel?.text = Localizable.Waves.Receiveaddress.Button.copied
         buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copied, for: .normal)

         DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDuration) {
             self.buttonCopy.isUserInteractionEnabled = true
             self.buttonCopy.tintColor = UIColor.submit400
             self.buttonCopy.setTitleColor(UIColor.submit400, for: .normal)
             self.buttonCopy.setImage(Images.copyAddress.image, for: .normal)
             self.buttonCopy.titleLabel?.text = Localizable.Waves.Receiveaddress.Button.copy
             self.buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copy, for: .normal)
         }
     }

     @IBAction private func shareTapped(_ sender: Any) {
        guard let model = model else { return }
        self.shareTapped?(model)
     }
}

// MARK: ViewConfiguration

extension ReceiveAddressCardView: ViewConfiguration {
    
    func update(with model: ReceiveAddress.DTO.Info) {
        self.model = model
        
        labelQRCode.text = Localizable.Waves.Receiveaddress.Label.yourQRCode
        buttonCopy.setTitle(Localizable.Waves.Receiveaddress.Button.copy, for: .normal)
        buttonShare.setTitle(Localizable.Waves.Receiveaddress.Button.share, for: .normal)

        labelAddress.text = model.address

        AssetLogo.logo(icon: model.icon,
                       style: .large)
            .observeOn(MainScheduler.instance)
            .bind(to: iconAsset.rx.image)
            .disposed(by: disposeBag)

        imageQR.image = QRCode(model.qrCode)?.image
    }
}
