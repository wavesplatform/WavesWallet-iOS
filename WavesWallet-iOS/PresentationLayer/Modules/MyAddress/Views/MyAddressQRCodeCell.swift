//
//  AddressesKeysAddressCell.swift
//  
//
//  Created by mefilt on 26/10/2018.
//

import UIKit
import QRCode
import CoreImage

private enum Constants {
    static let height: CGFloat = 228
    static let qrSize: CGSize = CGSize(width: 180, height: 180)
}

final class MyAddressQRCodeCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var qrImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }
}

// MARK: ViewConfiguration

extension MyAddressQRCodeCell: ViewConfiguration {

    struct Model {
        let address: String
    }

    func update(with model: MyAddressQRCodeCell.Model) {
        var qr = QRCode(model.address)        
        qr?.backgroundColor = CIColor(red: 248 / 255, green: 249 / 255, blue: 251 / 255)
        qr?.size = Constants.qrSize
        qrImageView.image = qr?.image 
    }
}

// MARK: ViewHeight

extension MyAddressQRCodeCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
// MARK: Localization

extension MyAddressQRCodeCell: Localization {

    func setupLocalization() {
        self.titleLabel.text = Localizable.Waves.Myaddress.Cell.Qrcode.title
    }
}

