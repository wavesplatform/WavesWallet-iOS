//
//  AccountPasswordTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation

enum AccountPasswordTypes {
    enum DTO {}
}

extension AccountPasswordTypes.DTO {
    enum Kind {
        case logIn(Wallet)
        case verifyAccess(Wallet)
    }
}

extension AccountPasswordTypes {
    struct State: Mutating {
        enum Query {
            case logIn(wallet: Wallet, password: String)
            case verifyAccess(wallet: Wallet, password: String)
            case authorizationCompleted(Wallet, String)
            case verifyAccessCompleted(SignedWallet, String)
        }

        var displayState: DisplayState
        var kind: AccountPasswordTypes.DTO.Kind
        var query: Query?
    }

    enum Event {
        case completedLogIn(Wallet, password: String)
        case completedVerifyAccess(SignedWallet, password: String)
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
