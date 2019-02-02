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
    static let wavesMinFee: Decimal = 0.001
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
        
        if model.asset.isWaves {
            labelSubtitle.text = model.wavesFee.displayText + " " + model.asset.displayName
        }
        else {
                    
            let sponsorFee = Money(model.asset.minSponsoredFee, model.asset.precision).decimalValue
            let value = (model.wavesFee.decimalValue / Constants.wavesMinFee) * sponsorFee
            let fee = Money(value: value, model.asset.precision)
            
            labelSubtitle.text = fee.displayText + " " + model.asset.displayName
        }

        labelTitle.text = model.asset.displayName
        
        let style = AssetLogo.Style(size: iconLogo.frame.size,
                                    font: UIFont.systemFont(ofSize: 15),
                                    border: nil)
        
        taskForAssetLogo = AssetLogo.logoFromCache(name: model.asset.icon, style: style, completionHandler: { [weak self] (image) in
            self?.iconLogo.image = image
        })
        
        
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image

    }
}

extension SendFeeTableViewCell: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
