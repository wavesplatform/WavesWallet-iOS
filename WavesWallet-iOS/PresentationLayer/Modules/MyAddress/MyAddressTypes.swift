//
//  AddressesKeysTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum MyAddressTypes {
    enum ViewModel { }
}

extension MyAddressTypes {

    enum Query: Equatable {
        case getAliases
        case getWallet
        case showInfo(aliases: [DomainLayer.DTO.Alias])
    }

    struct State: Mutating {
        var wallet: DomainLayer.DTO.Wallet?
        var aliases: [DomainLayer.DTO.Alias]
        var query: Query?
        var displayState: DisplayState
    }

    enum Event {
        case viewWillAppear
        case viewDidDisappear
        case setAliases([DomainLayer.DTO.Alias])
        case setWallet(DomainLayer.DTO.Wallet)
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

extension MyAddressTypes.ViewModel {

    enum Row {
        case aliases(Int)
        case address(String)        
        case qrcode(address: String)
        case skeleton
    }

    struct Section: SectionBase, Mutating {
        var rows: [Row]
    }
}
