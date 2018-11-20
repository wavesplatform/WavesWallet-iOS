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
    static let keyFont: UIFont = UIFont.systemFont(ofSize: 10)
}

protocol TransactionHistoryRecipientCellDelegate: class {
    func recipientCellDidPressContact(cell: TransactionHistoryRecipientCell, recipient: TransactionHistoryTypes.ViewModel.Recipient)
}

final class TransactionHistoryRecipientCell: UITableViewCell, NibReusable {
    
    weak var delegate: TransactionHistoryRecipientCellDelegate?
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var keyLabel: UILabel!
    
    @IBOutlet fileprivate weak var nameToKeyConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var contactButton: UIButton!

    private var recipient: TransactionHistoryTypes.ViewModel.Recipient?
    
    fileprivate static func title(for model: TransactionHistoryTypes.ViewModel.Recipient) -> String {
     
        var title = ""
        
        switch model.kind {
        case .sent:
            title = Localizable.Waves.Transactionhistory.Cell.sentTo

        case .receive:
            title = Localizable.Waves.Transactionhistory.Cell.receivedFrom

        case .startedLeasing:
            title = Localizable.Waves.Transactionhistory.Cell.leasingTo

        case .canceledLeasing:
            title = Localizable.Waves.Transactionhistory.Cell.from

        case .incomingLeasing:
            title = Localizable.Waves.Transactionhistory.Cell.from

        case .spamReceive:
            title = Localizable.Waves.Transactionhistory.Cell.receivedFrom
            
        case .massSent:
            title = Localizable.Waves.Transactionhistory.Cell.recipients

        case .massReceived:
            title = Localizable.Waves.Transactionhistory.Cell.recipients

        default:
            title = ""
        }
        
        return title
        
    }
    
    @IBAction func contactPressed(_ sender: Any) {
        guard let recipient = recipient else { return }
        delegate?.recipientCellDidPressContact(cell: self, recipient: recipient)
    }
}

extension TransactionHistoryRecipientCell: ViewCalculateHeight {
    
    typealias Model = TransactionHistoryTypes.ViewModel.Recipient
    
    static func viewHeight(model: TransactionHistoryTypes.ViewModel.Recipient, width: CGFloat) -> CGFloat {

        var isShort: Bool = false
        var title: String? = nil
        var value: String? = nil
        var key: String? = nil

        if model.isHiddenTitle {
            title = nil
        } else {
            title = TransactionHistoryRecipientCell.title(for: model)
        }

        let name = model.account.contact?.name
        let address = model.account.address

        if let name = name {
            value = name
        } else {
            value = address
        }

        if let amount = model.amount {
            key = amount.displayTextFull
        } else if name != nil {
            key = address
        } else {
            key = nil
        }

        isShort = (key != nil && title != nil)

        let titleHeight = title?.maxHeight(font: Constants.titleFont, forWidth: width) ?? 0
        let nameHeight = value?.maxHeight(font: Constants.nameFont, forWidth: width) ?? 0
        let keyHeight = key?.maxHeight(font: Constants.keyFont, forWidth: width) ?? 0

        let nameToAddressY: CGFloat = isShort == false ? Constants.nameToAddressY : 0

        let height = Constants.padding.top + titleHeight + Constants.titleToNameY + nameHeight + nameToAddressY + keyHeight + Constants.padding.bottom
        
        return height
    }
    
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {

        self.recipient = model

        var isShort: Bool = false
        var title: String? = nil
        var value: String? = nil
        var key: String? = nil

        if model.isHiddenTitle {
            title = nil
        } else {
            title = TransactionHistoryRecipientCell.title(for: model)
        }

        let name = model.account.contact?.name
        let address = model.account.address

        if let name = name {
            value = name
            contactButton.setImage(Images.editAddressIcon.image, for: .normal)
        } else {
            value = address
            contactButton.setImage(Images.addAddressIcon.image, for: .normal)
        }

        if let amount = model.amount {
            key = amount.displayTextFull
        } else if name != nil {
            key = address
        } else {
            key = nil
        }

        valueLabel.text = value
        titleLabel.text = title
        keyLabel.text = key

        isShort = (key != nil && title != nil)

        if isShort {
            nameToKeyConstraint.constant = 0
        } else {
            nameToKeyConstraint.constant = Constants.nameToAddressY
        }

        setNeedsUpdateConstraints()
    }
}
