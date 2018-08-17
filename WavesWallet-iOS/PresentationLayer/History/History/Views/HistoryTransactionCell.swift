//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryTransactionCell: UITableViewCell, Reusable {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewSpam: UIView!
    @IBOutlet weak var viewAssetType: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
    
}


extension HistoryTransactionCell: ViewConfiguration {
    
    func update(with model: HistoryTypes.DTO.Transaction) {
        
        viewSpam.isHidden = true
        viewAssetType.isHidden = false
        
        imageViewIcon.image = UIImage(named: HistoryTransactionImages[model.kind.rawValue])
        
        labelValue.attributedText = .styleForBalance(text: model.balance.displayTextFull, font: labelValue.font)
        
        var labelText = ""
        
        switch model.kind {
        case .massReceived:
            labelText = Localizable.History.Transactioncell.received + " " + model.name
        case .viewReceived:
            labelText = Localizable.History.Transactioncell.received + " " + model.name
        case .viewSend:
            labelText = Localizable.History.Transactioncell.sent + " " + model.name
        case .massSend:
            labelText = Localizable.History.Transactioncell.sent + " " + model.name
        case .createdAlias:
            labelText = Localizable.History.Transactioncell.alias
        case .viewLeasing:
            labelText = Localizable.History.Transactioncell.startedLeasing
        case .incomingLeasing:
            labelText = Localizable.History.Transactioncell.incomingLeasing
        case .canceledLeasing:
            labelText = Localizable.History.Transactioncell.canceledLeasing
        case .selfTranserred:
            labelText = Localizable.History.Transactioncell.selfTransfer + " " + model.name
        case .exchange:
            labelText = Localizable.History.Transactioncell.exchange // тут должно быть -0.00040000 BTC
        case .tokenGeneration:
            labelText = model.name + " " + Localizable.History.Transactioncell.tokenGeneration
        case .tokenBurning:
            labelText = Localizable.History.Transactioncell.tokenBurn
        case .tokenReissue:
            labelText = Localizable.History.Transactioncell.tokenReissue
        }
        
        labelTitle.text = labelText
        
    }
    
}
