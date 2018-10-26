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

    }

    struct State: Mutating {
        var query: Query?
        var wallet: DomainLayer.DTO.Wallet?
        var block: Int64?
        var displayState: DisplayState
    }

    enum Event {
//        case viewDidAppear
//        case viewDidDisappear
//        case tapRow(ProfileTypes.ViewModel.Row)
//        case setEnabledBiometric(Bool)
//        case setBlock(Int64)
//        case setWallet(DomainLayer.DTO.Wallet)
//        case setBackedUp(Bool)
//        case tapLogout
//        case tapDelete
//        case completedQuery
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
        case aliases
        case address
        case publicKey
        case hiddenPrivateKey
        case privateKey
    }

    struct Section: SectionBase, Mutating {
        var rows: [Row]
    }
}
