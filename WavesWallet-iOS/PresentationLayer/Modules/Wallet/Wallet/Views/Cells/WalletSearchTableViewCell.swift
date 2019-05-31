//
//  WalletSearchTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
    static let searchIconFrame: CGRect = .init(x: 0, y: 0, width: 36, height: 24)
}

final class WalletSearchTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var textField: UITextField!
    
    var searchTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageView = UIImageView(image: Images.search24Basic500.image)
        imageView.frame = Constants.searchIconFrame
        imageView.contentMode = .center
        textField.leftView = imageView
        textField.leftViewMode = .always
    }
    
    @IBAction private func searchButtonTapped(_ sender: Any) {
        searchTapped?()
    }
}

extension WalletSearchTableViewCell: ViewConfiguration {
    func update(with model: Void) {
        textField.attributedPlaceholder = NSAttributedString.init(string: Localizable.Waves.Wallet.Label.search, attributes: [NSAttributedString.Key.foregroundColor : UIColor.basic500])
    }
}

extension WalletSearchTableViewCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
