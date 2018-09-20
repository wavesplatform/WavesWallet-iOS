//
//  NewAccountPasscodeTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum NewAccountPasscodeTypes {
    enum DTO { }
}

extension NewAccountPasscodeTypes.DTO {
    
    enum Kind {
        case registration(Account)
    }

    struct Account: Hashable {
        let privateKey: PrivateKeyAccount
        let password: String
        let name: String
    }
}

extension NewAccountPasscodeTypes {

    enum PasswordKind: Hashable {
        case newPassword
        case repeatPassword
    }

    struct State: Mutating {

        enum Action {
            case registration
        }

        var displayState: DisplayState
        var kind: NewAccountPasscodeTypes.DTO.Kind
        var action: Action?
        var numbers: [PasswordKind: [Int]]
        var passcode: [Int]
    }

    enum Event {
        case completedRegistration
        case tapBack
        case completedInputNumbers([Int])
    }

    struct DisplayState: Mutating {

        enum Error {
            case incorrectPasscode
        }

        var kind: PasswordKind
        var numbers: [Int]
        var isLoading: Bool
        var isHiddenBackButton: Bool
        var error: Error?
    }
}
