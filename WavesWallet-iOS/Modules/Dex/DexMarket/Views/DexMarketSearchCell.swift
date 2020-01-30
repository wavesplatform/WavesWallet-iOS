//
//  DexMarketSearchCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 23.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer
import RxSwift

private enum Constants {
    static let height: CGFloat = 56
}

final class DexMarketSearchCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var iconFav: UIImageView!
    @IBOutlet private weak var iconAsset1: UIImageView!
    @IBOutlet private weak var iconAsset2: UIImageView!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    
        iconAsset1.addAssetPairIconShadow()
        iconAsset2.addAssetPairIconShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconAsset1.image = nil
        iconAsset2.image = nil
        disposeBag = DisposeBag()
    }
}


extension DexMarketSearchCell: ViewConfiguration {
    
    func update(with model: DexMarket.DTO.Pair) {
        
        let title = model.smartPair.amountAsset.shortName + " / " + model.smartPair.priceAsset.shortName
        
        let attr = NSMutableAttributedString(string: title)
        
        if let asset = model.selectedAsset {
            attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black,
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelTitle.font.pointSize, weight: .semibold)],
                               range: (title as NSString).range(of: asset.shortName))
        }
        
        labelTitle.attributedText = attr
        labelSubtitle.text = model.smartPair.amountAsset.name + " / " + model.smartPair.priceAsset.name
        iconFav.image = model.smartPair.isChecked ? Images.starSearchSmallActive.image : Images.starSearchSmall.image
        
        AssetLogo.logo(icon: model.smartPair.amountAsset.iconLogo, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: iconAsset1.rx.image)
            .disposed(by: disposeBag)
             
        AssetLogo.logo(icon: model.smartPair.priceAsset.iconLogo, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: iconAsset2.rx.image)
            .disposed(by: disposeBag)
    }
}

extension DexMarketSearchCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
