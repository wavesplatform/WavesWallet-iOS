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
 
    fileprivate func icon(for kind: TransactionHistoryTypes.DTO.Transaction.Kind) -> UIImage {
        
        var image: ImageAsset!
        
        switch kind {
        case .viewSend:
            image = Images.tSend48
        case .viewReceived:
            image = Images.assetReceive
        case .viewLeasing:
            image = Images.walletStartLease
        case .exchange:
            image = Images.tExchange48
        case .selfTranserred:
            image = Images.tSelftrans48
        case .tokenGeneration:
            image = Images.tTokengen48
        case .tokenReissue:
            image = Images.tTokenreis48
        case .tokenBurning:
            image = Images.tTokenburn48
        case .createdAlias:
            image = Images.tAlias48
        case .canceledLeasing:
            image = Images.tCloselease48
        case .incomingLeasing:
            image = Images.tIncominglease48
        case .massSend:
            image = Images.tMasstransfer48
        case .massReceived:
            image = Images.tMassreceived48
        case .spamReceived:
            image = Images.tSpamReceive48
        case .massSpamReceived:
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
        tagLabel.text = model.balance.currency.ticket
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


