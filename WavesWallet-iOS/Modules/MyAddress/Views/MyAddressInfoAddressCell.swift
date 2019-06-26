//
//  AddressesKeysPrivateKeyCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg

private enum Constants {
    static let height: CGFloat = 179
    static let iconSize: CGFloat = 48
}

protocol MyAddressInfoAddressCellDelegate: AnyObject {
    func myAddressInfoAddressCellDidTapShareAddress(_ address: String)
}

final class MyAddressInfoAddressCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var copyButton: PasteboardButton!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var iconImageView: UIImageView!
    
    weak var delegate: MyAddressInfoAddressCellDelegate?
    
    private let identity: Identity = Identity(options: Identity.defaultOptions)

    override func awakeFromNib() {
        super.awakeFromNib()        
        copyButton.isBlack = false
        setupLocalization()

        copyButton.copiedText = {
            return self.subTitleLabel.text
        }
    }

    @IBAction func actionTouchUpCopyButton(sender: Any) {
        delegate?.myAddressInfoAddressCellDidTapShareAddress(self.subTitleLabel.text ?? "")
    }
}

// MARK: ViewConfiguration

extension MyAddressInfoAddressCell: ViewConfiguration {
    struct Model {
        let address: String
    }

    func update(with model: Model) {
        self.subTitleLabel.text = model.address
        let image = identity.createImage(by: model.address, size: CGSize(width: Constants.iconSize, height: Constants.iconSize))
        iconImageView.image = image
    }
}

// MARK: ViewHeight

extension MyAddressInfoAddressCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: Localization

extension MyAddressInfoAddressCell: Localization {

    func setupLocalization() {
        titleLabel.text = Localizable.Waves.Myaddress.Cell.Info.title
        copyButton.setTitle(Localizable.Waves.Myaddress.Button.Copy.title, for: .normal)
        shareButton.setTitle(Localizable.Waves.Myaddress.Button.Share.title, for: .normal)
    }
}
