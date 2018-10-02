//
//  TransactionHistoryTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Mac on 28/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension TransactionHistoryTypes.State {
    
    func setCurrentIndex(_ index: Int) -> TransactionHistoryTypes.State {
        var newState = self
        newState.currentIndex = index
        return newState
    }
    
    func setDisplays(_ displays: [DisplayState]) -> TransactionHistoryTypes.State {
        var newState = self
        newState.displays = displays
        return newState
    }
    
    func setTransactions(_ transactions: [DomainLayer.DTO.SmartTransaction]) -> TransactionHistoryTypes.State {
        var newState = self
        newState.transactions = transactions
        return newState
    }
    
    
}

extension TransactionHistoryTypes.State {
    
    static func initialState(transactions: [DomainLayer.DTO.SmartTransaction], currentIndex: Int) -> TransactionHistoryTypes.State {
        
        var i = 0
        
        let displays = transactions.map { (transaction) -> TransactionHistoryTypes.State.DisplayState in
            
            i = i + 1
            
            return TransactionHistoryTypes.State.DisplayState(sections: TransactionHistoryTypes.ViewModel.Section.map(from: transaction, index: i - 1, count: transactions.count))
            
        }
        
        return TransactionHistoryTypes.State(currentIndex: currentIndex, displays: displays, transactions: transactions)
    }
    
}


