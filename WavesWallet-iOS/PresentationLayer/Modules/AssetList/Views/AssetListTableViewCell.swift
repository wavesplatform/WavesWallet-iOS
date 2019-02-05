//
//  AssetListTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher

private enum Constants {
    static let icon = CGSize(width: 24, height: 24)
    static let sponsoredIcon = CGSize(width: 10, height: 10)
    static let defaultTopTitleOffset: CGFloat = 10
}

final class AssetListTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var iconAsset: UIImageView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var iconCheckmark: UIImageView!
    @IBOutlet private weak var iconFav: UIImageView!
    @IBOutlet private weak var topTitleOffset: NSLayoutConstraint!
    
    private var taskForAssetLogo: RetrieveImageDiskTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        taskForAssetLogo?.cancel()
    }
    
}

extension AssetListTableViewCell: ViewConfiguration {
    
    struct Model {
        let asset:  DomainLayer.DTO.Asset
        let balance: Money
        let isChecked: Bool
        let isFavourite: Bool
    }
    
    func update(with model: Model) {
        
        let centerOffset = frame.size.height / 2 - labelAssetName.frame.size.height / 2
        topTitleOffset.constant = model.balance.isZero ? centerOffset : Constants.defaultTopTitleOffset
        labelAmount.isHidden = model.balance.isZero
        
        labelAssetName.text = model.asset.displayName
        iconFav.isHidden = !model.isFavourite
        
        labelAmount.text = model.balance.displayText

        let sponsoredIcon = model.asset.isSponsored ? Constants.sponsoredIcon : nil
        let style = AssetLogo.Style(size: Constants.icon,
                                    sponsoredSize: sponsoredIcon,
                                    font: UIFont.systemFont(ofSize: 15),
                                    border: nil)
        taskForAssetLogo = AssetLogo.logoFromCache(name: model.asset.icon, style: style, completionHandler: { [weak self] (image) in
            self?.iconAsset.image = image
        })
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image
    }
}
