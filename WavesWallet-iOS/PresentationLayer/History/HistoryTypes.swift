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
            case issue = 3
            case transfer = 4
            case reissue = 5
            case burn = 6
            case exchange = 7
            case lease = 8
            case leaseCancel = 9
            case alias = 10
            case massTransfer = 11
            case data = 12
            case setScript = 13
            case sponsorship = 14
        }
        
        let id: String
        let name: String
        let balance: Money
        let kind: Kind
        let tag: String
        let sortLevel: Float
    }
}

extension HistoryTypes.Filter {

    var kinds: [HistoryTypes.DTO.Transaction.Kind] {
        switch self {
        case .all:
            return [.issue, .transfer, .reissue, .burn, .exchange, .lease, .leaseCancel, .alias, .massTransfer, .data, .setScript, .sponsorship]
        case .sent:
            return [.transfer, .massTransfer]
        case .received:
            return [.transfer, .massTransfer]
        case .exchanged:
            return [.exchange]
        case .leased:
            return [.lease, .leaseCancel]
        case .issued:
            return [.issue, .reissue]
        case .activeNow:
            return [.lease]
        case .canceled:
            return [.leaseCancel]
            
        }
    }
    
    var name: String {
        switch self {
        case .all:
            return "All"
        case .sent:
            return "Sent"
        case .received:
            return "Received"
        case .exchanged:
            return "Exchanged"
        case .leased:
            return "Leased"
        case .issued:
            return "Issued"
        case .activeNow:
            return "Active Now"
        case .canceled:
            return "Canceled"
        }
    }
}

extension HistoryType {
    
    var filters: [HistoryTypes.Filter] {
        switch self {
        case .all:
            fallthrough
        case .asset(_):
            return [.all, .sent, .received, .exchanged, .leased, .issued]
        case .leasing(_):
            return [.all, .activeNow, .canceled]
        }
    }
    
}

