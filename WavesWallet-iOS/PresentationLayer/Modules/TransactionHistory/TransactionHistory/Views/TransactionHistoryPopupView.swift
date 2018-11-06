//
//  TransactionHistoryPopupView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryPopupView: UIView  {
    
    var contentView: NewTransactionHistoryContentView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView = NewTransactionHistoryContentView.loadView() as! NewTransactionHistoryContentView
        
        addSubview(contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds
    }
    
}
