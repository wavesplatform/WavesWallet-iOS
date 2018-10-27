//
//  AddressesKeysTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AddressesKeysTypes {
    enum ViewModel { }
}

extension AddressesKeysTypes {

    enum Query: Hashable {
        case getAliases
        case getPrivateKey
    }

    struct State: Mutating {
        var wallet: DomainLayer.DTO.Wallet
        var aliaces: [DomainLayer.DTO.Alias]
        var query: Query?
        var displayState: DisplayState
    }

    enum Event {
        case viewWillAppear
        case setAliaces([DomainLayer.DTO.Alias])
        case setPrivateKey(DomainLayer.DTO.SignedWallet)
//        case viewDidDisappear
//        case tapRow(ProfileTypes.ViewModel.Row)
//        case setEnabledBiometric(Bool)
//        case setBlock(Int64)
//        case setWallet(DomainLayer.DTO.Wallet)
//        case setBackedUp(Bool)
        case tapShowPrivateKey
//        case tapDelete
        case completedQuery
//        case none
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

extension AddressesKeysTypes.ViewModel {

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
