//
//  TransactionHistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryCoordinator: TransactionHistoryModuleInput {
    
    var transactions: [TransactionHistoryTypes.DTO.Transaction]
    var currentIndex: Int
    
    init(transactions: [TransactionHistoryTypes.DTO.Transaction], currentIndex: Int) {
        self.transactions = transactions
        self.currentIndex = currentIndex
    }
    
    private lazy var transactionHistoryViewController: UIViewController = {
        return TransactionHistoryModuleBuilder(output: self).build(input: self)
    }()
    
    func start() {
        let popupViewController = PopupViewController()
        popupViewController.present(contentViewController: transactionHistoryViewController)
    }
    
}

extension TransactionHistoryCoordinator: TransactionHistoryModuleOutput {
    
}

//extension TransactionHistoryCoordinator: TransactionHistoryModuleInput {
//
//    var transactions: [TransactionHistoryTypes.DTO.Transaction] { return transactions}
//    var currentIndex: Int { return currentIndex }
//
//
//}
