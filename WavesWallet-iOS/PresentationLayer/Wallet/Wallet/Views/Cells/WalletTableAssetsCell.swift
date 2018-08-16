//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher

private enum Constants {
    static let icon: CGSize = CGSize(width: 48,
                                     height: 48)
}

final class WalletTableAssetsCell: UITableViewCell, Reusable {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var iconArrow: UIImageView!
    @IBOutlet var iconStar: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    @IBOutlet var labelCryptoName: UILabel!
    @IBOutlet var viewFiatBalance: UIView!
    @IBOutlet var viewSpam: UIView!
    @IBOutlet var viewAssetType: UIView!
    private var taskForAssetLogo: RetrieveImageDiskTask?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewContent.layer.mask?.shadowColor = UIColor.black.cgColor
        viewContent.layer.mask?.shadowOffset = CGSize(width: 0, height: 10)
        viewContent.layer.mask?.shadowOpacity = 1.12
        viewContent.layer.mask?.shadowRadius = 1
        viewContent.layer.mask?.shouldRasterize = true
        viewContent.layer.mask?.rasterizationScale = UIScreen.main.scale
        viewContent.layer.mask?.shadowPath = UIBezierPath(roundedRect: viewContent.bounds.insetBy(dx: 0, dy: 0), cornerRadius: CGFloat(cornerRadius)).cgPath

        viewContent.layer.shadowColor = UIColor.black.cgColor
        viewContent.layer.shadowOffset = CGSize(width: 0, height: 10)
        viewContent.layer.shadowOpacity = 1.12
        viewContent.layer.shadowRadius = 1
        viewContent.layer.shouldRasterize = true
        viewContent.layer.rasterizationScale = UIScreen.main.scale
        viewContent.layer.shadowPath = UIBezierPath(roundedRect: viewContent.bounds.insetBy(dx: 0, dy: 0), cornerRadius: CGFloat(cornerRadius)).cgPath
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
        let name = model.name
        labelTitle.text = name

        viewSpam.isHidden = true
        iconStar.isHidden = !model.isFavorite
        viewFiatBalance.isHidden = true
        iconArrow.isHidden = model.isFiat == false && model.isGateway == false
        viewSpam.isHidden = model.kind != .spam
        let text = model.balance.displayTextFull

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)
        //TODO: Remove labelCryptoName
        labelCryptoName.isHidden = true

        taskForAssetLogo = AssetLogo.logoFromCache(name: model.name,
                                                   style: AssetLogo.Style(size: Constants.icon,
                                                                          font: UIFont.systemFont(ofSize: 22),
                                                                          border: nil)) { [weak self] image in
                                                                            self?.imageIcon.image = image
        }
    }
}
