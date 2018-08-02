//
//  HistoryTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.State {
    
    var currentDisplayState: HistoryTypes.State.DisplayState {
        switch display {
        case .all:
            return all
        case .sent:
            return sent
        case .received:
            return received
        case .exchanged:
            return exchanged
        case .leased:
            return leased
        case .issued:
            return issued
        case .activeNow:
            return activeNow
        case .canceled:
            return canceled
        }
    }
    
    func updateCurrentDisplay(state: DisplayState) -> HistoryTypes.State {
        var newState = self
        
        switch display {
        case .all:
            newState.all = state
        case .sent:
            newState.sent = state
        case .received:
            newState.received = state
        case .exchanged:
            newState.exchanged = state
        case .leased:
            newState.leased = state
        case .issued:
            newState.issued = state
        case .activeNow:
            newState.activeNow = state
        case .canceled:
            newState.canceled = state
        }
        
        return newState
    }
    
}

// MARK: Get Methods

extension HistoryTypes.State {
    
}

// MARK: Set Methods

extension HistoryTypes.State {
    
    func setAll(all: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.all = all
        return newState
    }
    
    func setSent(sent: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.sent = sent
        return newState
    }
    
    func setReceived(received: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.received = received
        return newState
    }
    
    func setExchanged(exchanged: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.exchanged = exchanged
        return newState
    }
    
    func setLeased(leased: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.leased = leased
        return newState
    }
    
    func setIssued(issued: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.issued = issued
        return newState
    }
    
    func setActiveNow(activeNow: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.activeNow = activeNow
        return newState
    }
    
    func setCanceled(canceled: DisplayState) -> HistoryTypes.State {
        var newState = self
        newState.canceled = canceled
        return newState
    }
}

extension HistoryTypes.State {
    static func initialState() -> HistoryTypes.State {
        return HistoryTypes.State(display: .all, all: .initialState(display: .all), sent: .initialState(display: .sent), received: .initialState(display: .received), exchanged: .initialState(display: .exchanged), leased: .initialState(display: .leased), issued: .initialState(display: .issued), activeNow: .initialState(display: .activeNow), canceled: .initialState(display: .canceled))
    }
}
