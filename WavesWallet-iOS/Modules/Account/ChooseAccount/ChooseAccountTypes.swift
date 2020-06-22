//
//  ChooseAccount.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

enum ChooseAccountTypes {
    enum DTO { }
}

extension ChooseAccountTypes {

    enum Action {
        case removeWallet(Wallet, indexPath: IndexPath)
        case editWallet(Wallet, indexPath: IndexPath)
        case openWallet(Wallet)
    }

    struct State: Mutating {
        var displayState: DisplayState
        var action: Action?
        var isAppeared: Bool
    }

    enum Event {
        case readyView
        case completedDeleteWallet(indexPath: IndexPath)
        case openWallet(Wallet, passcodeNotCreated: Bool)
        case tapEditButton(Wallet, indexPath: IndexPath)
        case tapRemoveButton(Wallet, indexPath: IndexPath)
        case tapWallet(Wallet)
        case setWallets([Wallet])
        case tapBack
        case tapAddAccount
        case viewDidDisappear
    }

    struct DisplayState: Mutating {

        enum Action {
            case none
            case reload
            case remove(indexPath: IndexPath)
        }

        var wallets: [Wallet]
        var action: DisplayState.Action
    }
}
