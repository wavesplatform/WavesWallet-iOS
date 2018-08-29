//
//  NewTransactionHistoryContentView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class NewTransactionHistoryContentView: UIView {
    
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MRK: - Setups
    
    private func setupTableView() {
        
    }
    
}

extension NewTransactionHistoryContentView {
    
    func setup(with: TransactionHistoryTypes.DTO.Transaction) {
        
    }
    
}
