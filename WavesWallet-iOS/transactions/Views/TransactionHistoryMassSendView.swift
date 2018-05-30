//
//  TransactionMassSendView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryMassSendView: UIView {

    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var viewSeparator: DottedLineView!
    @IBOutlet weak var labelTitle: UILabel!
    
    var hasAddedAddress = false
    
    var commentOffset: CGFloat {
        return 56
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = Platform.ScreenWidth
    }
    
    func setupInfo(_ item: NSDictionary, showComment: Bool) {
    
        hasAddedAddress = item["hasAddedAddress"] as? Bool ?? false
        
        if hasAddedAddress {
            buttonAdd.setImage(UIImage(named: "editaddress24Submit300"), for: .normal)
            labelTitle.text = "Mr. Big Mike"
        }
        else {
            labelTitle.text = "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0"
        }
        
        if let comment = item["comment"] as? String, showComment {
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
