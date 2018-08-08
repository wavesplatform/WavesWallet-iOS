//
//  HistoryTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.State {
    
}

// MARK: Get Methods

extension HistoryTypes.State {
    
}

// MARK: Set Methods

extension HistoryTypes.State {
    
    func setIsAppeared(_ isAppeared: Bool) -> HistoryTypes.State {
        var newState = self
        newState.isAppeared = isAppeared
        return newState
    }
    
    func setIsRefreshing(_ isRefreshing: Bool) -> HistoryTypes.State {
        var newState = self
        newState.isRefreshing = isRefreshing
        return newState
    }
    
    func setSections(sections: [HistoryTypes.ViewModel.Section]) -> HistoryTypes.State {
        var newState = self
        newState.sections = sections
        return newState
    }
    
    func setTransactions(transactions: [HistoryTypes.DTO.Transaction]) -> HistoryTypes.State {
        var newState = self
        newState.transactions = transactions
        return newState
    }
    
    func setStatus(status: HistoryTypes.Status) -> HistoryTypes.State {
        var newState = self
        newState.status = status
        return newState
//        var displayState = newState.currentDisplayState
//        displayState.animateType = .refresh
//        return newState.updateCurrentDisplay(state: displayState)
    }
}

extension HistoryTypes.State {
    static func initialState() -> HistoryTypes.State {
        var section: HistoryTypes.ViewModel.Section!
        
        section = HistoryTypes.ViewModel.Section(header: "Хедер", items: [.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton])
        
        return HistoryTypes.State(status: .all, transactions: [], sections: [section], isRefreshing: false, isAppeared: false)
    }
}
