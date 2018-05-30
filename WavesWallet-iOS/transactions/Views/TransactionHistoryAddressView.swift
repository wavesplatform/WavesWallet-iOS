//
//  TransactionAddressView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryAddressView: UIView {
  
    @IBOutlet weak var buttonAddAddress: UIButton!
    @IBOutlet weak var buttonTopOffset: NSLayoutConstraint!
    @IBOutlet weak var viewSeparator: DottedLineView!
    
    var state : HistoryTransactionState!
    var hasAddedAddress = false
    
    var item: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = Platform.ScreenWidth
    }
    
    var commentOffset: CGFloat {
        
       if state == .selfTranserred {
            if item["comment"] as? String != nil {
                return 16
            }
            return 0
        }
        else if state == .tokenGeneration || state == .tokenReissue {
            return 75
        }
        else if state == .massSend {
            return 75
        }
        else if hasAddedAddress {
            return 75
        }
        return 62
    }
    
  
    func setupInfo(_ item: NSDictionary, showComment: Bool) {
        
        self.item = item
        state = HistoryTransactionState(rawValue: item["state"] as! Int)!
        hasAddedAddress = item["hasAddedAddress"] as? Bool ?? false

        createTopLabel()
        createCenterLabel()

        if hasAddedAddress {
            buttonTopOffset.constant = 30
            buttonAddAddress.setImage(UIImage(named: "editaddress24Submit300"), for: .normal)
        }
        else if state == .massSend {
            buttonTopOffset.constant = 30
        }
        
        if hasAddedAddress || state == .tokenGeneration || state == .tokenReissue || state == .massSend {
            createBottomSmallLabel()
        }
        
        if state == .exchange || state == .selfTranserred || state == .tokenGeneration || state == .tokenReissue || state == .tokenBurning || state == .createdAlias {
            buttonAddAddress.isHidden = true
        }
        
        if state == .selfTranserred {
            viewSeparator.isHidden = true
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
    
    var labelLeftOffset: CGFloat {
        return 16
    }
    var labelWidth: CGFloat {
        return frame.size.width - 16 - 40
    }
    
    func createTopLabel() {
        let label = UILabel(frame: CGRect(x: labelLeftOffset, y: 13, width: labelWidth, height: 16))
        label.textColor = .basic500
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = transactionTextState(state)
        addSubview(label)
    }
    
    func createCenterLabel() {
        let label = UILabel(frame: CGRect(x: labelLeftOffset, y: 33, width: labelWidth, height: 16))
        label.textColor = .black
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 13)
        
        if state == .exchange {
            label.text = "3.00000000 Waves"
        }
        else if state == .selfTranserred {
            label.text = ""
        }
        else if state == .tokenGeneration || state == .tokenReissue || state == .tokenBurning {
            label.text = "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0"
        }
        else if state == .createdAlias {
            label.text = "0.001 Waves"
        }
        else if hasAddedAddress {
            label.text = "Mr. Big Mike"
        }
        else {
            label.text = "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0"
        }
        addSubview(label)
    }
    
    func createBottomSmallLabel() {
        let label = UILabel(frame: CGRect(x: labelLeftOffset, y: 50, width: labelWidth, height: 16))
        label.textColor = .basic700
        label.font = UIFont.systemFont(ofSize: 10)
        
        if state == .tokenGeneration || state == .tokenReissue {
            label.text = "Reissuable"
        }
        else if state == .massSend {
            label.text = "0.01000000"
        }
        else {
            label.text = "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0"
        }
        
        addSubview(label)
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
            return ""
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
            return "Fee"
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
