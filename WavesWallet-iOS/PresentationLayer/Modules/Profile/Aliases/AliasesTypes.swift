//
//  AliasesTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AliasesTypes {
    enum ViewModel { }
}

extension AliasesTypes {

    enum Query: Hashable {
        case calculateFee
        case createAlias
    }

    struct State: Mutating {
        var aliaces: [DomainLayer.DTO.Alias]
        var query: Query?
        var displayState: DisplayState
    }

    enum Event {
        case viewWillAppear
        case tapCreateAlias
        case completedQuery
        case handlerError(Error)
        case setFee(Money)
    }

    struct DisplayState: Mutating, DataSourceProtocol {

        enum Action {
            case none
            case update
        }

        enum TransactionFee {
            case progress
            case fee(Money)
        }

        var sections: [ViewModel.Section]
        var isAppeared: Bool
        var action: Action?
        var error: DisplayError?
        var transactionFee: TransactionFee
        var isEnabledCreateAliasButton: Bool
    }
}

extension AliasesTypes.ViewModel {

    enum Row {
        case alias(DomainLayer.DTO.Alias)
        case head
    }

    struct Section: SectionBase, Mutating {
        var rows: [Row]
    }
}
