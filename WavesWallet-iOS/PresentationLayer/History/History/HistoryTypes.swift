//
//  HistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxDataSources

enum HistoryTypes {
    enum DTO {}
    enum ViewModel {}
    
    enum Filter {
        case all
        case sent
        case received
        case exchanged
        case leased
        case issued
        case activeNow
        case canceled
    }
    
    struct State: Mutating {
        var currentFilter: Filter
        var filters: [Filter]
        var transactions: [HistoryTypes.DTO.Transaction]
        var sections: [HistoryTypes.ViewModel.Section]
        var isRefreshing: Bool
        var isAppeared: Bool
    }
    
    enum Event {
        case responseAll([DTO.Transaction])
        case readyView
        case refresh
        case changeFilter(Filter)
    }
}

extension HistoryTypes.DTO {
    struct Transaction: Hashable, Mutating {
        enum Kind: Int {
            case viewReceived = 0
            case viewSend
            case viewLeasing
            case exchange // not show comment, not show address
            case selfTranserred // not show address
            case tokenGeneration // show ID token
            case tokenReissue // show ID token,
            case tokenBurning // show ID token, do not have bottom state of token
            case createdAlias // show ID token
            case canceledLeasing
            case incomingLeasing
            case massSend // multiple addresses
            case massReceived
        }
        
        let id: String
        let name: String
        let balance: Money
        let kind: Kind
        let tag: String
        let date: NSDate
        let sortLevel: Float
    }
}

extension HistoryTypes.Filter {
    // TODO: посмотреть точно все типы, когда какой показывается
    var kinds: [HistoryTypes.DTO.Transaction.Kind] {
        switch self {
        case .all:
            return [
            .viewReceived,
            .viewSend,
            .viewLeasing,
            .exchange, // not show comment, not show address
            .selfTranserred, // not show address
            .tokenGeneration, // show ID token
            .tokenReissue, // show ID token,
            .tokenBurning, // show ID token, do not have bottom state of token
            .createdAlias, // show ID token
            .canceledLeasing,
            .incomingLeasing,
            .massSend, // multiple addresses
            .massReceived
            ]
        case .sent:
            return [.viewSend, .massSend]
        case .received:
            return [.viewReceived, .massReceived]
        case .exchanged:
            return [.exchange]
        case .leased:
            return [.viewLeasing, .incomingLeasing]
        case .issued:
            return [.tokenReissue]
        case .activeNow:
            return [.viewLeasing]
        case .canceled:
            return [.canceledLeasing]
        }
    }
    
    var name: String {
        switch self {
        case .all:
            return Localizable.History.Segmentedcontrol.all
        case .sent:
            return Localizable.History.Segmentedcontrol.sent
        case .received:
            return Localizable.History.Segmentedcontrol.received
        case .exchanged:
            return Localizable.History.Segmentedcontrol.exchanged
        case .leased:
            return Localizable.History.Segmentedcontrol.leased
        case .issued:
            return Localizable.History.Segmentedcontrol.issued
        case .activeNow:
            return Localizable.History.Segmentedcontrol.activeNow
        case .canceled:
            return Localizable.History.Segmentedcontrol.canceled
        }
    }
}

extension HistoryType {
    
    var filters: [HistoryTypes.Filter] {
        switch self {
        case .all:
            fallthrough
        case .transaction(_):
            return [.all, .sent, .received, .exchanged, .leased, .issued]
        case .leasing(_):
            return [.all, .activeNow, .canceled]
        }
    }
    
}

