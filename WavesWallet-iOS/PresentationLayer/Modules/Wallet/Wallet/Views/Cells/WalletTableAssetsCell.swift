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
    func update(with model: WalletTypes.DTO.Asset) {
        
        labelTitle.attributedText = NSAttributedString.styleForMyAssetName(assetName: model.name,
                                                                           isMyAsset: model.isMyWavesToken)

        viewSpam.isHidden = true
        iconStar.isHidden = !model.isFavorite
        viewFiatBalance.isHidden = true
        iconArrow.isHidden = model.isFiat == false && model.isGateway == false
        viewSpam.isHidden = model.isSpam == false
        let text = model.balance.displayTextFull

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)

        taskForAssetLogo = AssetLogo.logoFromCache(name: model.icon,
                                                   style: AssetLogo.Style(size: Constants.icon,
                                                                          font: UIFont.systemFont(ofSize: 22),
                                                                          border: nil)) { [weak self] image in
                                                                            self?.imageIcon.image = image
        }
    }
}
