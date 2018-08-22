//
//  HistoryTransactionView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 21/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryTransactionView: UIView, NibOwnerLoadable {
    
    struct Transaction {
        enum Kind: Int {
            case viewReceived = 0
            case viewSend
            case viewLeasing
            case exchange // not show comment, not show address
            case selfTranserred // not show address
            case tokenGeneration // show ID token
            case tokenReissue // show ID token,
            case tokenBurning // show ID token, do not have bottom state of token
            case createdAlias // show ID token
            case canceledLeasing
            case incomingLeasing
            case massSend // multiple addresses
            case massReceived
        }
        
        let id: String
        let name: String
        let balance: Money
        let kind: Kind
        let tag: String
        let date: NSDate
    }
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewSpam: UIView!
    @IBOutlet weak var viewAssetType: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContainer.addTableCellShadowStyle()
    }
    
}

extension HistoryTransactionView: ViewConfiguration {
    
    func update(with model: Transaction) {
        
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

extension HistoryTransactionView.Transaction {
    init(with transaction: HistoryTypes.DTO.Transaction) {
        let kind = HistoryTransactionView.Transaction.Kind(rawValue: transaction.kind.rawValue)!
        
        self.init(id: transaction.id, name: transaction.name, balance: transaction.balance, kind: kind, tag: transaction.tag, date: transaction.date)
    }
}
