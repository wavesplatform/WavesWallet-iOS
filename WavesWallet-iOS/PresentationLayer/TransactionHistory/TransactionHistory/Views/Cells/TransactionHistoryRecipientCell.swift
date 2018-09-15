//
//  TransactionHistoryRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let padding: UIEdgeInsets = Platform.isIphone5 ? UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12) : UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    static let titleToNameY: CGFloat = 6
    static let nameToAddressY: CGFloat = 2
}

final class TransactionHistoryRecipientCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var nameToKeyConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate static func title(for model: TransactionHistoryTypes.ViewModel.Recipient) -> String {
     
        var title = ""
        
        switch model.kind {
        case .sent:
            title = "Sent to"
        case .receive:
            title = "Recieved from"
        case .startedLeasing:
            title = "Leasing to"
        case .canceledLeasing:
            title = "From"
        case .incomingLeasing:
            title = "From"
        case .massSent:
            title = "Recipient"
        case .massReceived:
            title = "From"
        default:
            title = ""
        }
        
        return title
        
    }
    
}

extension TransactionHistoryRecipientCell: ViewCalculateHeight {
    
    typealias Model = TransactionHistoryTypes.ViewModel.Recipient
    
    static func viewHeight(model: TransactionHistoryTypes.ViewModel.Recipient, width: CGFloat) -> CGFloat {
        
        let titleHeight = title(for: model).maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: width)
        
        let nameToAddressY: CGFloat = (model.name != nil) ? Constants.nameToAddressY : 0
        
        let nameHeight = model.name?.maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: width) ?? 0
        let addressHeight = model.address.maxHeight(font: UIFont.systemFont(ofSize: 10), forWidth: width)
        
        return Constants.padding.top + titleHeight + Constants.titleToNameY + nameHeight + nameToAddressY + addressHeight + Constants.padding.bottom
    }
    
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {
        
        titleLabel.text = TransactionHistoryRecipientCell.title(for: model)
        
        if model.name != nil {
            valueLabel.text = model.name
            keyLabel.text = model.address
        } else {
            valueLabel.text = model.address
            keyLabel.text = ""
        }
        
        nameToKeyConstraint.constant = model.name != nil ? Constants.nameToAddressY : 0
        
        setNeedsUpdateConstraints()
    }
}
