//
//  ChangePasswordTypes.swift
//  
//
//  Created by mefilt on 16/10/2018.
//

import Foundation

enum ChangePasswordTypes {
    enum DTO { }
}

extension ChangePasswordTypes {

    enum Query {
        case confirmPassword(wallet: DomainLayer.DTO.Wallet, old: String, new: String)
    }

    enum FieldKind {
        case oldPassword
        case newPassword
        case confirmPassword
    }

    struct State: Mutating {
        var wallet: DomainLayer.DTO.Wallet
        var displayState: DisplayState
        var query: Query?
        var isAppeared: Bool
        var textFields: [FieldKind: String]
        var isValidOldPassword: Bool
        var isValidConfirmPassword: Bool
    }

    enum Event {
        case readyView
        case input(FieldKind, String?)
        case handlerError(AuthorizationInteractorError)
        case successOldPassword
        case tapContinue
        case completedQuery
    }

    struct DisplayState: Mutating {

        struct TextField: Mutating {
            var error: String? 
            var isEnabled: Bool
        }

//        enum Error {
//            case wrongOldPassword
//        }
//
//        var error: Error?
        var textFields: [FieldKind: TextField] 
        var isEnabledConfirmButton: Bool
    }
}
