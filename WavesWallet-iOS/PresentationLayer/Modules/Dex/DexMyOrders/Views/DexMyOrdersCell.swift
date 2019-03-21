//
//  DexMyOrdersCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cancelAlpha: CGFloat = 0.45
    static let defaultAlpha: CGFloat = 1
}

final class DexMyOrdersCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelSide: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelFilled: UILabel!
    @IBOutlet private weak var viewSeparate: UIView!
    
    var buttonInfoDidTap: ((DomainLayer.DTO.Dex.MyOrder) -> Void)?
    private var order: DomainLayer.DTO.Dex.MyOrder?
    
    @IBAction private func infoTapped(_ sender: Any) {
        guard let order = order else { return }
        buttonInfoDidTap?(order)
    }
}

extension DexMyOrdersCell: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.Dex.MyOrder) {
        
        order = model
        
        labelDate.text = DexMyOrders.ViewModel.dateFormatterDate.string(from: model.time)
        labelTime.text = DexMyOrders.ViewModel.dateFormatterTime.string(from: model.time)
        labelStatus.text = model.statusText
        labelPrice.text = model.price.displayText
        labelSide.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
        labelPrice.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
        labelFilled.text = String(model.percentFilled) + "%"

        labelDate.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
        labelTime.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
        labelStatus.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
        labelSide.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
        labelPrice.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
        labelFilled.alpha = model.status == .cancelled ? Constants.cancelAlpha : Constants.defaultAlpha
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
