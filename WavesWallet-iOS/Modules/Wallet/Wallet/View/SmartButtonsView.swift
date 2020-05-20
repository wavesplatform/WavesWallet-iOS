//
//  WalletSearchView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 56
    static let searchIconFrame: CGRect = .init(x: 0, y: 0, width: 36, height: 24)
}

final class SmartButtonsView: UITableViewCell, NibLoadable {
    
    
//    @IBOutlet private weak var textField: UITextField!

//    var searchTapped: (() -> Void)?
//    var sortTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
//
//        let imageView = UIImageView(image: Images.search24Basic500.image)
//        imageView.frame = Constants.searchIconFrame
//        imageView.contentMode = .center
//        textField.leftView = imageView
//        textField.leftViewMode = .always
//    }

//    @IBAction private func searchButtonTapped(_: Any) {
//        searchTapped?()
//    }
//
//    @IBAction private func sortButtonTapped(_: Any) {
//        sortTapped?()
//    }
}
//
//extension SmartButtonsView: ViewConfiguration {
//    func update(with _: Void) {
//        textField
//            .attributedPlaceholder = NSAttributedString(string: Localizable.Waves.Wallet.Label.search,
//                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.basic500])
//    }
//}
//
//extension SmartButtonsView: ViewHeight {
//    static func viewHeight() -> CGFloat {
//        return Constants.height
//    }
//}

