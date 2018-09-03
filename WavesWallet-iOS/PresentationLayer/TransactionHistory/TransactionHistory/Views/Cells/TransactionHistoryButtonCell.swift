//
//  TransactionHistoryButtonCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryButtonCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    class func cellHeight() -> CGFloat {
        return 64
    }
}

extension TransactionHistoryButtonCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.ResendButton) {
        var title = ""
        var buttonBackground: UIColor?
        var icon: UIImage
        
        switch model.type {
        case .resend:
            title = "Send again"
            buttonBackground = UIColor(red: 248, green: 147, blue: 0)
            icon = Images.resendIcon.image
        case .cancelLeasing:
            title = "Cancel leasing"
            buttonBackground = UIColor(red: 229, green: 73, blue: 77)
            icon = Images.closeLeaseIcon.image
        }
        
        button.setTitle(title, for: .normal)
        button.setImage(icon, for: .normal)
        button.backgroundColor = buttonBackground
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
    }
}

