//
//  AddressesKeysTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum MyAddressesKeysTypes {
    enum ViewModel { }
}

extension MyAddressesKeysTypes {

    enum Query: Equatable {
        case getAliases
        case getPrivateKey
        case showInfo(aliases: [DomainLayer.DTO.Alias])
    }

    struct State: Mutating {
        var wallet: DomainLayer.DTO.Wallet
        var aliases: [DomainLayer.DTO.Alias]
        var query: Query?
        var displayState: DisplayState
    }

    enum Event {
        case viewWillAppear
        case viewDidDisappear
        case setAliases([DomainLayer.DTO.Alias])
        case setPrivateKey(DomainLayer.DTO.SignedWallet)
        case tapShowPrivateKey
        case tapShowInfo
        case completedQuery
    }

    struct DisplayState: Mutating, DataSourceProtocol {

        enum Action {
            case none
            case update
        }

        var sections: [ViewModel.Section]
        var isAppeared: Bool
        var action: Action?
    }
}

extension MyAddressesKeysTypes.ViewModel {

    enum Row {
        case aliases(Int)
        case address(String)
        case publicKey(String)
        case hiddenPrivateKey
        case privateKey(String)
        case skeleton
    }

    struct Section: SectionBase, Mutating {
        var rows: [Row]
    }
}
