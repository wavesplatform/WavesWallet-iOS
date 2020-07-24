//
//  TradeTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Extensions
import RxSwift
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 70
    static let percentFontSize: CGFloat = 12
}

final class TradeTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var imageViewIcon1: UIImageView!
    @IBOutlet private weak var imageViewIcon2: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelVolume: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var buttonFav: UIButton!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewPercent: PercentTickerView!

    private var disposeBag = DisposeBag()

    var favoriteTappedAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        imageViewIcon1.addAssetPairIconShadow()
        imageViewIcon2.addAssetPairIconShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewIcon1.image = nil
        imageViewIcon2.image = nil
        disposeBag = DisposeBag()
    }

    @IBAction private func favoriteTapped(_: Any) {
        favoriteTappedAction?()
    }
}

extension TradeTableViewCell: ViewConfiguration {
    func update(with model: TradeTypes.DTO.Pair) {
        let title = model.amountAsset.displayName + " / " + model.priceAsset.displayName
        let attr = NSMutableAttributedString(string: title)
        if let asset = model.selectedAsset {
            var searchAssetString: String {
                if model.amountAsset.id == asset.id {
                    return asset.displayName + " /"
                }
                return "/ " + asset.displayName
            }
            let range = (title as NSString).range(of: searchAssetString)
            let font = UIFont.systemFont(ofSize: labelTitle.font.pointSize, weight: .medium)
            attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.basic500,
                                NSAttributedString.Key.font: font], range: range)
        }
        labelTitle.attributedText = attr
        labelVolume.text = model.lastPrice.displayText
        labelPrice.text = "$" + model.priceUSD.displayText
        buttonFav.setImage(model.isFavorite ? Images.favorite14Submit300.image : Images.iconFavEmpty.image, for: .normal)

        viewPercent.update(with: .init(firstPrice: model.firstPrice.doubleValue,
                                       lastPrice: model.lastPrice.doubleValue,
                                       fontSize: Constants.percentFontSize))

        AssetLogo.logo(icon: model.amountAsset.iconLogo, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon1.rx.image)
            .disposed(by: disposeBag)

        AssetLogo.logo(icon: model.priceAsset.iconLogo, style: .medium)
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
