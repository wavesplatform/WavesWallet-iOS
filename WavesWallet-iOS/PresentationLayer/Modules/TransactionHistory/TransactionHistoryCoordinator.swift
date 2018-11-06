//
//  TransactionHistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryCoordinator: TransactionHistoryModuleInput {
    
    let transactions: [DomainLayer.DTO.SmartTransaction]
    let currentIndex: Int
    let rootViewController: UIViewController
    
    init(transactions: [DomainLayer.DTO.SmartTransaction],
         currentIndex: Int,
         rootViewController: UIViewController) {
        
        self.rootViewController = rootViewController
        self.transactions = transactions
        self.currentIndex = currentIndex
    }
    
    private lazy var transactionHistoryViewController: TransactionHistoryViewController = {
        return TransactionHistoryModuleBuilder(output: self).build(input: self) as! TransactionHistoryViewController
    }()
    
    func start() {
        transactionHistoryViewController.transitioningDelegate = transactionHistoryViewController
        transactionHistoryViewController.modalPresentationStyle = .custom
        rootViewController.present(transactionHistoryViewController, animated: true, completion: nil)
    }
}

extension TransactionHistoryCoordinator: TransactionHistoryModuleOutput {}

