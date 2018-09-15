//
//  TransactionHistoryGeneralCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryGeneralCell: UITableViewCell, NibReusable {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var nextButtonPressed: UIButton!
    @IBOutlet weak var previousButtonPressed: UIButton!
    
    @IBOutlet weak var tagLabel: UILabel!
    
   @IBOutlet weak var valueLabelXConstraint: NSLayoutConstraint!
    
    class func cellHeight() -> CGFloat {
        return 170
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagContainer.borderColor = UIColor(red: 121 , green: 149, blue:  185)
        tagContainer.borderWidth = 0.5
        tagContainer.layer.cornerRadius = 2
    }
 
    fileprivate func icon(for kind: DomainLayer.DTO.SmartTransaction.Kind) -> UIImage {
        
        var image: ImageAsset!
        
        switch kind {
        case .sent:
            image = Images.tSend48
        case .receive:
            image = Images.assetReceive
        case .startedLeasing:
            image = Images.walletStartLease
        case .exchange:
            image = Images.tExchange48
        case .selfTransfer:
            image = Images.tSelftrans48
        case .tokenGeneration:
            image = Images.tTokengen48
        case .tokenReissue:
            image = Images.tTokenreis48
        case .tokenBurn:
            image = Images.tTokenburn48
        case .createdAlias:
            image = Images.tAlias48
        case .canceledLeasing:
            image = Images.tCloselease48
        case .incomingLeasing:
            image = Images.tIncominglease48
        case .massSent:
            image = Images.tMasstransfer48
        case .massReceived:
            image = Images.tMassreceived48
        case .spamReceive:
            image = Images.tSpamReceive48
        case .spamMassReceived:
            image = Images.tSpamReceive48
        case .data:
            image = Images.tData48
        case .unrecognisedTransaction:
            image = Images.tAlias48
        }
        
        return UIImage(asset: image)
        
    }
    
}

extension TransactionHistoryGeneralCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.General) {
        
        valueLabel.attributedText = .styleForBalance(text: model.balance.money.displayTextFull, font: valueLabel.font)
        
        iconImageView.image = icon(for: model.kind)
        tagLabel.text = model.balance.currency.ticker
        currencyLabel.text = model.currencyConversion
        
        let tagSize = tagLabel.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        
        valueLabelXConstraint.constant = tagSize.width / -2
        
        setNeedsUpdateConstraints()
        
    }
    
}

extension TransactionHistoryGeneralCell: ViewCalculateHeight {
    
    static func viewHeight(model: TransactionHistoryTypes.ViewModel.General, width: CGFloat) -> CGFloat {
        if model.currencyConversion != nil {
            return 148
        }
        
        return 170
    }
    
}


