//
//  TransactionHistoryShowAllView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryShowAllView: UIView {

    @IBOutlet weak var buttonShow: UIButton!
    @IBOutlet weak var viewSeparator: DottedLineView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = Platform.ScreenWidth
    }

    var commentOffset: CGFloat {
        return 44
    }
    
    func setupInfo(_ item: NSDictionary) {
        
        if let comment = item["comment"] as? String {
            viewSeparator.isHidden = true
            
            let commentView = TransactionCommentView.loadView() as! TransactionCommentView
            commentView.frame.origin.y = commentOffset
            commentView.setup(comment: comment)
            addSubview(commentView)
            frame.size.height = commentOffset + commentView.frame.size.height
        }
        else {
            frame.size.height = commentOffset
        }
    }
}
