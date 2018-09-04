//
//  TransactionHistoryCommentCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryCommentCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func cellHeight(width: CGFloat, model: TransactionHistoryTypes.ViewModel.Comment) -> CGFloat {
        return 12 + 12 + model.text.maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: width - 12 - 12 - 12 - 12)
    }
}

extension TransactionHistoryCommentCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Comment) {
        
        commentLabel.text = model.text
        
    }
}
