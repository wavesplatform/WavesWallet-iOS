//
//  HistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

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
        var transactions: [DomainLayer.DTO.SmartTransaction]
        var sections: [HistoryTypes.ViewModel.Section]
        var isRefreshing: Bool
        var isAppeared: Bool
    }
    
    enum Event {
        case responseAll([DomainLayer.DTO.SmartTransaction])
        case readyView
        case refresh
        case changeFilter(Filter)
        case tapCell(IndexPath)
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    var isIncludedAllGroup: Bool {
        switch kind {
        default:
            return true
        }
    }

    var isIncludedSentGroup: Bool {
        switch kind {
        case .sent, .massSent:
            return true
        default:
            return false
        }
    }

    var isIncludedReceivedGroup: Bool {
        switch kind {
        case .spamReceive, .spamMassReceived:
            return true
        default:
            return false
        }
    }

    var isIncludedExchangedGroup: Bool {
        switch kind {
        case .exchange:
            return true
        default:
            return false
        }
    }

    var isIncludedLeasedGroup: Bool {
        switch kind {
        case .canceledLeasing, .incomingLeasing, .startedLeasing:
            return true
        default:
            return false
        }
    }

    var isIncludedIssuedGroup: Bool {
        switch kind {
        case .tokenBurn, .tokenReissue, .tokenGeneration:
            return true
        default:
            return false
        }
    }

    var isIncludedActiveNowGroup: Bool {
        switch kind {
        case .startedLeasing:
            return true
        default:
            return false
        }
    }

    var isIncludedCanceledGroup: Bool {
        switch kind {
        case .canceledLeasing:
            return true
        default:
            return false
        }
    }
}

extension HistoryTypes.Filter {

    func isNeedTransaction(where kind: DomainLayer.DTO.SmartTransaction) -> Bool {

        switch self {
        case .all:
            return kind.isIncludedAllGroup

        case .sent:
            return kind.isIncludedSentGroup

        case .received:
            return kind.isIncludedReceivedGroup

        case .exchanged:
            return kind.isIncludedExchangedGroup

        case .leased:
            return kind.isIncludedLeasedGroup

        case .issued:
            return kind.isIncludedIssuedGroup

        case .activeNow:
            return kind.isIncludedActiveNowGroup

        case .canceled:
            return kind.isIncludedCanceledGroup
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
        case .asset:
            return [.all, .sent, .received, .exchanged, .leased, .issued]
        case .leasing:
            return [.all, .activeNow, .canceled]
        }
    }
}
