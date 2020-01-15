//
//  TradeTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import RxSwift

private enum Constants {
    static let height: CGFloat = 70
}

final class TradeTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var imageViewIcon1: UIImageView!
    @IBOutlet private weak var imageViewIcon2: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelVolume: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var buttonFav: UIButton!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewPercent: UIView!
    @IBOutlet private weak var labelPercent: UILabel!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        imageViewIcon1.addAssetPairIconShadow()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewIcon1.image = nil
        imageViewIcon2.image = nil
        disposeBag = DisposeBag()
    }
    
    func test() {
        let wavesURL = "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/v3/waves.png"
        let btcURL = "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/v3/bitcoin.png"
        
        let iconWaves = AssetLogo.Icon(assetId: "WAVES", name: "WAVES", url: wavesURL, isSponsored: false, hasScript: false)
        let iconBTC = AssetLogo.Icon(assetId: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", name: "Bitcoin", url: btcURL, isSponsored: false, hasScript: false)
        
        let percent = arc4random() % 3
        if percent == 0 {
            labelPercent.text = "+2.37%"
            labelPercent.textColor = .success500
            viewPercent.backgroundColor = .success500
        }
        else if percent == 1 {
            labelPercent.text = "-1.23%"
            labelPercent.textColor = .error500
            viewPercent.backgroundColor = .error500
        }
        else {
            labelPercent.text = "0.0%"
            labelPercent.textColor = .basic500
            viewPercent.backgroundColor = .basic500
        }
        AssetLogo.logo(icon: iconWaves, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon1.rx.image)
            .disposed(by: disposeBag)
              
        AssetLogo.logo(icon: iconBTC, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon2.rx.image)
            .disposed(by: disposeBag)
    }
}

extension TradeTableViewCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
