//
//  DexMyOrdersCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import MGSwipeTableCell
import RxSwift
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 90
    static let canceledAlpha: CGFloat = 0.4
}

final class DexMyOrdersCell: MGSwipeTableCell, NibReusable {
    @IBOutlet private weak var imageViewIcon1: UIImageView!
    @IBOutlet private weak var imageViewIcon2: UIImageView!
    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelAssets: UILabel!
    @IBOutlet private weak var labelAmountTitle: UILabel!
    @IBOutlet private weak var labelSumTitle: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelSum: UILabel!
    @IBOutlet private weak var labelTypeTitle: UILabel!
    @IBOutlet private weak var labelPriceTitle: UILabel!
    @IBOutlet private weak var labelStatusTitle: UILabel!
    @IBOutlet private weak var labelType: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelFilledPercent: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelFilled: UILabel!

    @IBOutlet private var labels: [UILabel]!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        for label in labels {
            label.font = UIFont.robotoRegular(size: label.font.pointSize)
        }
        setupLocalization()
        imageViewIcon1.addAssetPairIconShadow()
        imageViewIcon2.addAssetPairIconShadow()
    }

    private func setupLocalization() {
        labelAmountTitle.text = Localizable.Waves.Dexmyorders.Label.amount
        labelSumTitle.text = Localizable.Waves.Dexmyorders.Label.sum
        labelTypeTitle.text = Localizable.Waves.Dexmyorders.Label.type
        labelPriceTitle.text = Localizable.Waves.Dexmyorders.Label.price
        labelStatusTitle.text = Localizable.Waves.Dexmyorders.Label.status
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewIcon1.image = nil
        imageViewIcon2.image = nil
        disposeBag = DisposeBag()
    }
}

extension DexMyOrdersCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

extension DexMyOrdersCell: ViewConfiguration {
    struct Model {
        let order: DomainLayer.DTO.Dex.MyOrder
        let index: Int
    }

    func update(with model: Model) {
        let order = model.order

        labelAssets.text = order.amountAsset.displayName + "/" + order.priceAsset.displayName
        labelAmount.text = order.amount.displayText
        labelSum.text = order.totalBalance.money.displayText
        labelFilled.text = order.filled.displayText
        labelFilledPercent.text = String(order.filledPercent) + "%"
        labelStatus.text = order.statusText
        labelDate.text = DexMyOrders.ViewModel.dateFormatter.string(from: order.time)
        labelPrice.text = order.price.displayText
        labelType.text = order.type == .sell ? Localizable.Waves.Dexmyorders.Label.sell : Localizable.Waves.Dexmyorders.Label.buy
        labelType.textColor = order.type == .sell ? UIColor.error500 : UIColor.submit400
        labelPrice.textColor = order.type == .sell ? UIColor.error500 : UIColor.submit400

        backgroundColor = model.index % 2 == 0 ? .basic50 : .basic100

        contentView.alpha = 1
        if order.status == .cancelled {
            contentView.alpha = Constants.canceledAlpha
        }

        AssetLogo.logo(icon: order.amountAsset.iconLogo, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon1.rx.image)
            .disposed(by: disposeBag)

        AssetLogo.logo(icon: order.priceAsset.iconLogo, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon2.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: - DomainLayer.DTO.Dex.MyOrder

fileprivate extension DomainLayer.DTO.Dex.MyOrder {
    var statusText: String {
        switch status {
        case .accepted:
            return Localizable.Waves.Dexmyorders.Label.Status.accepted

        case .partiallyFilled:
            return Localizable.Waves.Dexmyorders.Label.Status.partiallyFilled

        case .cancelled:
            return Localizable.Waves.Dexmyorders.Label.Status.cancelled

        case .filled:
            return Localizable.Waves.Dexmyorders.Label.Status.filled
        }
    }
}
