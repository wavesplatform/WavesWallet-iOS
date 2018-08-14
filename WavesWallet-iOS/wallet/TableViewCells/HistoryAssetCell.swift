//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HistoryAssetCell: UITableViewCell, Reusable {

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
    
    func setupCell(value: String, state: HistoryTransactionState) {
        
        labelValue.attributedText = NSAttributedString.styleForBalance(text: value, font: labelValue.font)
        imageViewIcon.image = UIImage(named: HistoryTransactionImages[state.rawValue])
        
        if state == .viewReceived {
            labelTitle.text = "Received " + "Waves"
        }
        else if state == .viewSend {
            labelTitle.text = "Sent " + "Waves"
        }
        else if state == .viewLeasing {
            labelTitle.text = "Started Leasing"
        }
        else if state == .exchange {
            labelTitle.text = "-0.00400000" + " " + "Waves"
        }
        else if state == .selfTranserred {
            labelTitle.text = "Self-transfer " + "Waves"
        }
        else if state == .tokenGeneration {
            labelTitle.text = "Waves" + " - Token Generation"
        }
        else if state == .tokenReissue {
            labelTitle.text = "Waves" + " Token Reissue"
        }
        else if state == .tokenBurning {
            labelTitle.text = "Waves" + " Token Burn"
        }
        else if state == .createdAlias {
            labelTitle.text = "Create Alias"
        }
        else if state == .canceledLeasing {
            labelTitle.text = "Canceled Leasing"
        }
        else if state == .incomingLeasing {
            labelTitle.text = "Incoming Leasing"
        }
        else if state == .massSend {
            labelTitle.text = "Send " + "Waves"
        }
        else if state == .massReceived {
            labelTitle.text = "Received " + "Waves"
        }
            
    }
}


extension HistoryAssetCell: ViewConfiguration {
    
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
        
        setNeedsUpdateConstraints()
        
    }
    
}
