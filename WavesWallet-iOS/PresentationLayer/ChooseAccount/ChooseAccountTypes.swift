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

    struct State: Mutating {

        enum Action {
            
        }

        var displayState: DisplayState
        var action: Action?
        var isAppeared: Bool
    }

    enum Event {
        case readyView
        case tapEditButton(DomainLayer.DTO.Wallet)
        case tapRemoveButton(DomainLayer.DTO.Wallet)
        case tapWallet(DomainLayer.DTO.Wallet)
        case setWallets([DomainLayer.DTO.Wallet])
    }

    struct DisplayState: Mutating {
        var wallets: [DomainLayer.DTO.Wallet]
    }
}
