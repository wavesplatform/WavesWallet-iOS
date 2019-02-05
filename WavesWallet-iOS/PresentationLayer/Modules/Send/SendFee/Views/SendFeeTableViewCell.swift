//
//  SendFeeTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher

private enum Constants {
    static let height: CGFloat = 56
    static let icon = CGSize(width: 28, height: 28)
    static let sponsoredIcon = CGSize(width: 12, height: 12)
    static let noneActiveAlpha: CGFloat = 0.3
}

final class SendFeeTableViewCell: UITableViewCell, Reusable {

    @IBOutlet private weak var iconLogo: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var iconCheckmark: UIImageView!

    private var taskForAssetLogo: RetrieveImageDiskTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        taskForAssetLogo?.cancel()
    }
}

extension SendFeeTableViewCell: ViewConfiguration {
    
    func update(with model: SendFee.DTO.SponsoredAsset) {

        labelTitle.text = model.asset.displayName
        
        let sponsoredSize = model.asset.isSponsored ? Constants.sponsoredIcon : nil
        let style = AssetLogo.Style(size: Constants.icon,
                                    sponsoredSize: sponsoredSize,
                                    font: UIFont.systemFont(ofSize: 15),
                                    border: nil)
        
        taskForAssetLogo = AssetLogo.logoFromCache(name: model.asset.icon, style: style, completionHandler: { [weak self] (image) in
            self?.iconLogo.image = image
        })
        
        
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image
        labelTitle.textColor = model.isActive ? .black : .blueGrey
        iconLogo.alpha = model.isActive ? 1 : Constants.noneActiveAlpha

        let feeText =  model.fee.displayText + " " + model.asset.displayName
        labelSubtitle.text = model.isActive ? feeText : Localizable.Waves.Sendfee.Label.notAvailable
    }
}

extension SendFeeTableViewCell: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
