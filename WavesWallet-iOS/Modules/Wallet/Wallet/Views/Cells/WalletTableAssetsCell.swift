//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import Extensions
import DomainLayer

fileprivate enum Constants {
    static let height: CGFloat = 76
}

final class WalletTableAssetsCell: UITableViewCell, NibReusable {
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet private var viewContent: UIView!
    @IBOutlet private var iconStar: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelSubtitle: UILabel!
    @IBOutlet private var viewSpam: UIView!
    @IBOutlet private weak var labelSpam: UILabel!
    private var disposeBag: DisposeBag = DisposeBag()
    
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
        imageIcon.image = nil
        disposeBag = DisposeBag()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

extension WalletTableAssetsCell: ViewConfiguration {
    func update(with model: DomainLayer.DTO.SmartAssetBalance) {
        
        labelTitle.attributedText = NSAttributedString.styleForMyAssetName(assetName: model.asset.displayName,
                                                                           isMyAsset: model.asset.isMyWavesToken)

        viewSpam.isHidden = true
        iconStar.isHidden = !model.settings.isFavorite
        viewSpam.isHidden = model.asset.isSpam == false
        let balance = Money(model.availableBalance, model.asset.precision)
        let text = balance.displayShortText

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)
        
        AssetLogo.logo(icon: model.asset.iconLogo,
                       style: .large)
            .observeOn(MainScheduler.instance)
            .bind(to: imageIcon.rx.image)
            .disposed(by: disposeBag)

    }
}
