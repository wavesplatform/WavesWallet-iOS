//
//  TransactionHistoryButtonCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol TransactionHistoryButtonCellDelegate: class {
    func transactionButtonCellDidPress(cell: TransactionHistoryButtonCell)
}

private enum Constants {
    static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
}

final class TransactionHistoryButtonCell: UITableViewCell, NibReusable {
    
    weak var delegate: TransactionHistoryButtonCellDelegate?
    
    @IBOutlet weak var button: HighlightedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    }
    
    class func cellHeight() -> CGFloat {
        return 58
    }
    
    @objc private func buttonPressed(sender: Any) {
        
        delegate?.transactionButtonCellDidPress(cell: self)
    }
    
}

extension TransactionHistoryButtonCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.ResendButton) {
        
        var title = ""
        var buttonBackground: UIColor?
        var buttonHighlightedBackground: UIColor?
        var icon: UIImage
        
        switch model.type {
        case .resend:
            
            title = Localizable.TransactionHistory.Cell.Button.sendAgain
            buttonBackground = UIColor.warning600
            buttonHighlightedBackground = UIColor.warning400
            icon = Images.resendIcon.image
            
        case .cancelLeasing:
            
            title = Localizable.TransactionHistory.Cell.Button.cancelLeasing
            buttonBackground = UIColor.error400
            buttonHighlightedBackground = UIColor.error700
            icon = Images.closeLeaseIcon.image
            
        }
        
        button.setTitle(title, for: .normal)
        button.setImage(icon, for: .normal)
        button.backgroundColor = buttonBackground
        button.highlightedBackground = buttonHighlightedBackground
        button.titleEdgeInsets = Constants.titleEdgeInsets
        
    }
}

