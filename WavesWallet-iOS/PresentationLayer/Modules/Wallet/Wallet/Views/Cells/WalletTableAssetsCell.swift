//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

fileprivate enum Constants {
    static let height: CGFloat = 76    
    static let icon: CGSize = CGSize(width: 48, height: 48)
    static let sponsoredIcon = CGSize(width: 18, height: 18)
}

final class WalletTableAssetsCell: UITableViewCell, Reusable {
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet private var viewContent: UIView!
    @IBOutlet private var iconStar: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelSubtitle: UILabel!
    @IBOutlet private var viewFiatBalance: UIView!
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
        viewFiatBalance.isHidden = true
        viewSpam.isHidden = model.asset.isSpam == false
        let balance = Money(model.availableBalance, model.asset.precision)
        let text = balance.displayShortText

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)

        let sponsoredSize = model.asset.isSponsored ? Constants.sponsoredIcon : nil
        AssetLogo.logo(icon: model.asset.iconLogo,
                       style: AssetLogo.Style(size: Constants.icon,
                                              sponsoredSize: sponsoredSize,
                                              font: UIFont.systemFont(ofSize: 22),
                                              border: nil))
            .bind(to: imageIcon.rx.image)
            .disposed(by: disposeBag)

    }
}
