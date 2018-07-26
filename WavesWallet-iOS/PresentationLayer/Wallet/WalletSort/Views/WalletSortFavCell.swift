//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let height: CGFloat = 48
}

final class WalletSortFavCell: UITableViewCell, Reusable {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var iconLock: UIImageView!
    @IBOutlet var arrowGreen: UIImageView!    
    @IBOutlet var labelCryptoName: UILabel!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

extension WalletSortFavCell: ViewConfiguration {
    struct Model {
        let name: String
        let isMyAsset: Bool
        let isLock: Bool
        let isGateway: Bool
    }

    func update(with model: WalletSortFavCell.Model) {
        let cryptoName = model.name
        labelTitle.text = cryptoName
        iconLock.isHidden = !model.isLock
        arrowGreen.isHidden = !model.isGateway
        
        let iconName = DataManager.logoForCryptoCurrency(cryptoName)
        if iconName.count == 0 {
            labelCryptoName.text = String(cryptoName.first!).uppercased()
            imageIcon.image = nil
            imageIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(cryptoName)
        } else {
            labelCryptoName.text = nil
            imageIcon.image = UIImage(named: iconName)
        }
    }
}
