//
//  AccountPasswordTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AccountPasswordTypes {
    enum DTO { }
}

extension AccountPasswordTypes {

    struct State: Mutating {

        enum Action {
            case logIn(password: String)
            case authorizationCompleted
        }

        var displayState: DisplayState
        var wallet: DomainLayer.DTO.Wallet
        var action: Action?
    }

    enum Event {
        case completedLogIn
        case handlerError(AccountPasswordInteractorError)
        case tapLogIn(password: String)
    }

    struct DisplayState: Mutating {

        enum Error {
            case incorrectPassword
        }

        var isLoading: Bool
        var error: Error?
        var name: String
        var address: String
    }
}
