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
}

final class AssetListTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var iconAsset: UIImageView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var iconGateway: UIImageView!
    @IBOutlet private weak var iconCheckmark: UIImageView!
    @IBOutlet private weak var iconFav: UIImageView!
    
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
        
        labelAssetName.text = model.asset.name
        iconGateway.isHidden = !model.asset.isGateway
        iconFav.isHidden = !model.isFavourite
        
        labelAmount.text = model.balance.displayTextFull

        let style = AssetLogo.Style(size: Constants.icon, font: UIFont.systemFont(ofSize: 15), border: nil)
        taskForAssetLogo = AssetLogo.logoFromCache(name: model.asset.ticker ?? model.asset.name, style: style, completionHandler: { [weak self] (image) in
            self?.iconAsset.image = image
        })
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image
    }
}
