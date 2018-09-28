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
    
    static let titleFont: UIFont = UIFont.systemFont(ofSize: 13)
    static let nameFont: UIFont = UIFont.systemFont(ofSize: 13)
    static let addressFont: UIFont = UIFont.systemFont(ofSize: 10)
}

protocol TransactionHistoryRecipientCellDelegate: class {
    
    func recipientCellDidPressContact(cell: TransactionHistoryRecipientCell)
    
}

final class TransactionHistoryRecipientCell: UITableViewCell, NibReusable {
    
    weak var delegate: TransactionHistoryRecipientCellDelegate?
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var keyLabel: UILabel!
    
    @IBOutlet fileprivate weak var nameToKeyConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var contactButton: UIButton!
    
    fileprivate static func title(for model: TransactionHistoryTypes.ViewModel.Recipient) -> String {
     
        var title = ""
        
        switch model.kind {
        case .sent:
            title = Localizable.TransactionHistory.Cell.sentTo
        case .receive:
            title = Localizable.TransactionHistory.Cell.receivedFrom
        case .startedLeasing:
            title = Localizable.TransactionHistory.Cell.leasingTo
        case .canceledLeasing:
            title = Localizable.TransactionHistory.Cell.from
        case .incomingLeasing:
            title = Localizable.TransactionHistory.Cell.from
        case .massSent:
            title = Localizable.TransactionHistory.Cell.recipient
        case .massReceived:
            title = Localizable.TransactionHistory.Cell.recipient
        default:
            title = ""
        }
        
        return title
        
    }
    
    @IBAction func contactPressed(_ sender: Any) {
        delegate?.recipientCellDidPressContact(cell: self)
    }
    
}

extension TransactionHistoryRecipientCell: ViewCalculateHeight {
    
    typealias Model = TransactionHistoryTypes.ViewModel.Recipient
    
    static func viewHeight(model: TransactionHistoryTypes.ViewModel.Recipient, width: CGFloat) -> CGFloat {
        
        let titleHeight = title(for: model).maxHeight(font: Constants.titleFont, forWidth: width)
        
        let nameLabelText = model.name ?? model.address
        let nameHeight = nameLabelText.maxHeight(font: Constants.nameFont, forWidth: width)
        
        let nameToAddressY: CGFloat = (model.name != nil) ? Constants.nameToAddressY : 0
        
        let addressHeight = (model.name != nil) ? model.address.maxHeight(font: Constants.addressFont, forWidth: width) : 0
        
        let height = Constants.padding.top + titleHeight + Constants.titleToNameY + nameHeight + nameToAddressY + addressHeight + Constants.padding.bottom
        
        return height
    }
    
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {
        
        titleLabel.text = TransactionHistoryRecipientCell.title(for: model)
        
        if model.name != nil {
            valueLabel.text = model.name
            keyLabel.text = model.address
            contactButton.setImage(Images.editAddressIcon.image, for: .normal)
        } else {
            valueLabel.text = model.address
            keyLabel.text = ""
            contactButton.setImage(Images.addAddressIcon.image, for: .normal)
        }
        
        nameToKeyConstraint.constant = model.name != nil ? Constants.nameToAddressY : 0
        
        setNeedsUpdateConstraints()
    }
}
