//
//  WalletSortCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let height: CGFloat = 56
}

final class WalletSortCell: UITableViewCell, Reusable {
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var arrowGreen: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var iconMenu: UIImageView!
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var labelCryptoName: UILabel!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconMenu.isHidden = true
        viewContent.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

extension WalletSortCell: ViewConfiguration {
    struct Model {
        let name: String
        let isMyAsset: Bool
        let isVisibility: Bool
        let isHidden: Bool
        let isGateway: Bool
    }

    func update(with model: Model) {

        //TODO: My asset
        let cryptoName = model.name
        labelTitle.text = cryptoName
        switchControl.isHidden = model.isVisibility
        switchControl.isOn = model.isHidden
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
