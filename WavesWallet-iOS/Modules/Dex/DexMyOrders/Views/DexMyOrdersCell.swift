//
//  DexMyOrdersCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions
import RxSwift

final class DexMyOrdersCell: UITableViewCell, NibReusable {

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
    @IBOutlet private weak var viewBgCanceled: UIView!
    
    @IBOutlet private var labels: [UILabel]!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        for label in labels {
            label.font = UIFont.robotoRegular(size: label.font.pointSize)
        }
        setupLocalization()
        
        imageViewIcon1.layer.shadowColor = UIColor.black.cgColor
        imageViewIcon1.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageViewIcon1.layer.shadowOpacity = 0.2
        imageViewIcon1.layer.shadowRadius = 3
        imageViewIcon1.clipsToBounds = false
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


extension DexMyOrdersCell: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.Dex.MyOrder) {
                
        labelAssets.text = model.amountAsset.shortName + "/" + model.priceAsset.shortName
        labelAmount.text = model.amount.displayText
        labelSum.text = model.totalBalance.money.displayText
        labelFilled.text = model.filled.displayText
        labelFilledPercent.text = String(model.filledPercent) + "%"
        labelStatus.text = model.statusText
        labelDate.text = DexMyOrders.ViewModel.dateFormatter.string(from: model.time)
        labelPrice.text = model.price.displayText
        labelType.text = model.type == .sell ? Localizable.Waves.Dexmyorders.Label.sell : Localizable.Waves.Dexmyorders.Label.buy
        labelType.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
        labelPrice.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400

        viewBgCanceled.isHidden = model.status != .cancelled
        
        AssetLogo.logo(icon: model.amountAssetIcon, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon1.rx.image)
            .disposed(by: disposeBag)
        
        AssetLogo.logo(icon: model.priceAssetIcon, style: .medium)
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon2.rx.image)
            .disposed(by: disposeBag)
    }
}

//MARK: - DomainLayer.DTO.Dex.MyOrder
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
