//
//  TransactionBaseView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryBaseView: UIView {

    @IBOutlet weak var viewSeparator: DottedLineView!

    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = Platform.ScreenWidth
    }
    
    var viewHeight : CGFloat {
        return 0
    }
    
    func setupInfo(_ item: NSDictionary) {
        
        for view in subviews.filter({$0.isKind(of: TransactionCommentView.classForCoder())}) {
            view.removeFromSuperview()
        }
        
        if let comment = item["comment"] as? String {
            viewSeparator.isHidden = true
            
            let commentView = TransactionCommentView.loadView() as! TransactionCommentView
            commentView.frame.origin.y = viewHeight
            commentView.setup(comment: comment)
            addSubview(commentView)
            frame.size.height = viewHeight + commentView.frame.size.height
        }
        else {
            viewSeparator.isHidden = false
            frame.size.height = viewHeight
        }
    }
    
    
    func transactionTextState(_ state: HistoryTransactionState) -> String {
        if state == .viewReceived {
            return "Received from"
        }
        else if state == .viewSend {
            return "Sent to"
        }
        else if state == .viewLeasing {
            return "Leasing to"
        }
        else if state == .exchange {
            return "Waves" + " Price"
        }
        else if state == .selfTranserred {
            return "ID"
        }
        else if state == .tokenGeneration {
            return "ID"
        }
        else if state == .tokenReissue {
            return "ID"
        }
        else if state == .tokenBurning {
            return "ID"
        }
        else if state == .createdAlias {
            return "ID"
        }
        else if state == .canceledLeasing {
            return "From"
        }
        else if state == .incomingLeasing {
            return "From"
        }
        else if state == .massSend {
            return "Recipient"
        }
        else if state == .massReceived {
            return "From"
        }
        return ""
    }
}
