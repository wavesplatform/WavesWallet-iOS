//
//  ChooseAccount.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import Foundation

enum ChooseAccountTypes {
    enum DTO { }
}

extension ChooseAccountTypes.DTO {

}

extension ChooseAccountTypes {

    enum Action {
        case removeWallet(DomainLayer.DTO.Wallet, indexPath: IndexPath)
    }

    struct State: Mutating {
        var displayState: DisplayState
        var action: Action?
        var isAppeared: Bool
    }

    enum Event {
        case readyView
        case completedDeleteWallet(indexPath: IndexPath)
        case tapEditButton(DomainLayer.DTO.Wallet)
        case tapRemoveButton(DomainLayer.DTO.Wallet, indexPath: IndexPath)
        case tapWallet(DomainLayer.DTO.Wallet)
        case setWallets([DomainLayer.DTO.Wallet])        
    }

    struct DisplayState: Mutating {

        enum Action {
            case none
            case reload
            case remove(indexPath: IndexPath)
        }

        var wallets: [DomainLayer.DTO.Wallet]
        var action: DisplayState.Action
    }
}
