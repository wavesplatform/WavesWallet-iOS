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
    
    class func cellHeight() -> CGFloat {
        return 192
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
        case .viewSend(_):
            image = Images.tSend48
        case .viewReceived(_):
            image = Images.assetReceive
        case .viewLeasing(_):
            image = Images.walletStartLease
        case .exchange(_):
            image = Images.tExchange48
        case .selfTranserred(_):
            image = Images.tSelftrans48
        case .tokenGeneration(_):
            image = Images.tTokengen48
        case .tokenReissue(_):
            image = Images.tTokenreis48
        case .tokenBurning(_):
            image = Images.tTokenburn48
        case .createdAlias(_):
            image = Images.tAlias48
        case .canceledLeasing(_):
            image = Images.tCloselease48
        case .incomingLeasing(_):
            image = Images.tIncominglease48
        case .massSend(_):
            image = Images.tMasstransfer48
        case .massReceived(_):
            image = Images.tMassreceived48
        }
        
        return UIImage(asset: image)
        
    }
    
}

extension TransactionHistoryGeneralCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.General) {
        
        let values = model.value.split(separator: ".")
        
        let string = NSMutableAttributedString(string: model.value)
        
        for (i, value) in values.enumerated() {
            if i == 0 {
                string.addAttributes([NSAttributedStringKey.font : UIFont.bodySemibold], range: NSMakeRange(0, value.count))
            } else {
                string.addAttributes([NSAttributedStringKey.font : UIFont.bodyRegular], range: NSMakeRange(0, value.count))
            }
        }
        
        iconImageView.image = icon(for: model.kind)
        tagLabel.text = model.tag
        currencyLabel.text = model.currencyConversion
        
        
    }
    
}


