//
//  SendFeeTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

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

    private var disposeBag: DisposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

extension SendFeeTableViewCell: ViewConfiguration {
    
    func update(with model: SendFee.DTO.SponsoredAsset) {

        labelTitle.text = model.assetBalance.asset.displayName
        
        let sponsoredSize = model.assetBalance.asset.isSponsored ? Constants.sponsoredIcon : nil
        let style = AssetLogo.Style(size: Constants.icon,
                                    sponsoredSize: sponsoredSize,
                                    font: UIFont.systemFont(ofSize: 15),
                                    border: nil)

        AssetLogo.logo(icon: model.assetBalance.asset.iconLogo,
                       style: style)
            .bind(to: iconLogo.rx.imageAnimationFadeIn)
            .disposed(by: disposeBag)
        
        iconCheckmark.image = model.isChecked ? Images.on.image : Images.off.image
        labelTitle.textColor = model.isActive ? .black : .blueGrey
        iconLogo.alpha = model.isActive ? 1 : Constants.noneActiveAlpha
        iconCheckmark.isHidden = !model.isActive
        
        let feeText =  model.fee.displayText + " " + model.assetBalance.asset.displayName
        labelSubtitle.text = model.isActive ? feeText : Localizable.Waves.Sendfee.Label.notAvailable
    }
}

extension SendFeeTableViewCell: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
