//
//  TransactionHistoryCommentCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    static let boxPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    static let fontSize: CGFloat = 13
}

final class TransactionHistoryCommentCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak private(set) var commentLabel: UILabel!

}

extension TransactionHistoryCommentCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Comment) {
        
        commentLabel.text = model.text
        
    }
}

extension TransactionHistoryCommentCell: ViewCalculateHeight {
    class func viewHeight(model: TransactionHistoryTypes.ViewModel.Comment, width: CGFloat) -> CGFloat {
        
        let padding = Constants.padding
        let boxPadding = Constants.boxPadding
        
        let modelHeight = model.text.maxHeight(
            font: UIFont.systemFont(ofSize: Constants.fontSize),
            forWidth: width - padding.left - padding.right - boxPadding.left - boxPadding.right)
        
        return padding.top +
            padding.bottom +
            boxPadding.top +
            boxPadding.bottom + modelHeight
        
    }
}
