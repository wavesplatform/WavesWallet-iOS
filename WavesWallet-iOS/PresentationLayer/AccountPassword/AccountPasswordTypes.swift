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

extension AccountPasswordTypes.DTO {
    enum Kind {
        case logIn(DomainLayer.DTO.Wallet)
        case verifyAccess(DomainLayer.DTO.Wallet)
    }
}

extension AccountPasswordTypes {

    struct State: Mutating {

        enum Query {
            case logIn(wallet: DomainLayer.DTO.Wallet, password: String)
            case verifyAccess(wallet: DomainLayer.DTO.Wallet, password: String)
            case authorizationCompleted(DomainLayer.DTO.Wallet, String)
            case verifyAccessCompleted(DomainLayer.DTO.SignedWallet, String)
        }

        var displayState: DisplayState
        var kind: AccountPasswordTypes.DTO.Kind
        var query: Query?        
    }

    enum Event {
        case completedLogIn(DomainLayer.DTO.Wallet, password: String)
        case completedVerifyAccess(DomainLayer.DTO.SignedWallet, password: String)
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
