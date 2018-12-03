//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate enum Constants {
    static let icon: CGSize = CGSize(width: 48,
                                     height: 48)
}

final class WalletTableAssetsCell: UITableViewCell, Reusable {
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet private var viewContent: UIView!
    @IBOutlet private var iconArrow: UIImageView!
    @IBOutlet private var iconStar: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelSubtitle: UILabel!
    @IBOutlet private var viewFiatBalance: UIView!
    @IBOutlet private var viewSpam: UIView!
    @IBOutlet private weak var labelSpam: UILabel!
    private var taskForAssetLogo: RetrieveImageDiskTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        labelSpam.text = Localizable.Waves.General.Ticker.Title.spam
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        taskForAssetLogo?.cancel()
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}

extension WalletTableAssetsCell: ViewConfiguration {
    func update(with model: DomainLayer.DTO.AssetBalance) {
        
        labelTitle.attributedText = NSAttributedString.styleForMyAssetName(assetName: model.asset!.displayName,
                                                                           isMyAsset: model.asset!.isMyWavesToken)

        viewSpam.isHidden = true
        iconStar.isHidden = !model.settings!.isFavorite
        viewFiatBalance.isHidden = true
        iconArrow.isHidden = model.asset!.isFiat == false && model.asset!.isGateway == false
        viewSpam.isHidden = model.asset!.isSpam == false
        let balance = Money.init(model.avaliableBalance, model.asset!.precision)
        let text = balance.displayShortText

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)

        taskForAssetLogo = AssetLogo.logoFromCache(name: model.asset!.icon,
                                                   style: AssetLogo.Style(size: Constants.icon,
                                                                          font: UIFont.systemFont(ofSize: 22),
                                                                          border: nil)) { [weak self] image in
                                                                            self?.imageIcon.image = image
        }
    }
}
