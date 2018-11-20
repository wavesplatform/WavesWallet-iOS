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
            if model.account.contact == nil {
                title = Localizable.Waves.Transactionhistory.Cell.recipient
            }

        case .massReceived:
            title = Localizable.Waves.Transactionhistory.Cell.recipient

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

        let name = model.account.contact?.name
        let address = model.account.address

        let titleHeight = title(for: model).maxHeight(font: Constants.titleFont, forWidth: width)
        
        let nameLabelText = name ?? address
        let nameHeight = nameLabelText.maxHeight(font: Constants.nameFont, forWidth: width)
        
        let nameToAddressY: CGFloat = (name != nil) ? Constants.nameToAddressY : 0
        
        let addressHeight = (name != nil) ? address.maxHeight(font: Constants.addressFont, forWidth: width) : 0
        
        let height = Constants.padding.top + titleHeight + Constants.titleToNameY + nameHeight + nameToAddressY + addressHeight + Constants.padding.bottom
        
        return height
    }
    
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {

        self.recipient = model
        titleLabel.text = TransactionHistoryRecipientCell.title(for: model)

        let name = model.account.contact?.name
        let address = model.account.address

        if name != nil {
            valueLabel.text = name
            contactButton.setImage(Images.editAddressIcon.image, for: .normal)
        } else {
            valueLabel.text = address
            contactButton.setImage(Images.addAddressIcon.image, for: .normal)
        }

        if let amount = model.amount {
            keyLabel.attributedText = NSAttributedString.styleForBalance(text: amount.displayTextFull, font: keyLabel.font!)
            nameToKeyConstraint.constant = Constants.nameToAddressY
        } else {
            keyLabel.text = ""
            nameToKeyConstraint.constant = 0
        }

        setNeedsUpdateConstraints()
    }
}
