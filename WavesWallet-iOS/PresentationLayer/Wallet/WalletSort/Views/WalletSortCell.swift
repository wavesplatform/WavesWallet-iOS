//
//  WalletSortCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxSwift
import UIKit
import Kingfisher

private enum Constants {
    static let height: CGFloat = 56
    static let icon: CGSize = CGSize(width: 28,
                                     height: 28)
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

    private var taskForAssetLogo: RetrieveImageDiskTask?
    private(set) var disposeBag = DisposeBag()

    var changedValueSwitchControl: ((Bool) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        taskForAssetLogo?.cancel()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        iconMenu.isHidden = true
        viewContent.addTableCellShadowStyle()
        switchControl.addTarget(self, action: #selector(changedValueSwitchAction), for: .valueChanged)
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }

    @objc func changedValueSwitchAction() {
        changedValueSwitchControl?(switchControl.isOn)
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
        // TODO: My asset
        let cryptoName = model.name
        labelTitle.text = cryptoName
        switchControl.isHidden = model.isVisibility
        switchControl.isOn = model.isHidden
        arrowGreen.isHidden = !model.isGateway
        labelCryptoName.isHidden = true

        taskForAssetLogo = UIImage.assetLogoFromCache(name: cryptoName,
                                                      size: Constants.icon,
                                                      font: UIFont.systemFont(ofSize: 15)) { [weak self] image in
            self?.imageIcon.image = image
        }
    }
}
