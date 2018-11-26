//
//  NewAccountPasscodeTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum PasscodeTypes {
    enum DTO { }
}

extension PasscodeTypes.DTO {
    
    enum Kind {
        case verifyAccess(DomainLayer.DTO.Wallet)
        case registration(Account)
        case logIn(DomainLayer.DTO.Wallet)
        case changePasscode(DomainLayer.DTO.Wallet)
        case changePasscodeByPassword(DomainLayer.DTO.Wallet, password: String)
        case setEnableBiometric(Bool, wallet: DomainLayer.DTO.Wallet)
        case changePassword(wallet: DomainLayer.DTO.Wallet, newPassword: String, oldPassword: String)
    }

    struct Account: Hashable {
        let privateKey: PrivateKeyAccount
        let password: String
        let name: String
        let needBackup: Bool
    }
}

extension PasscodeTypes {

    enum PasscodeKind: Hashable {
        case oldPasscode
        case newPasscode
        case repeatPasscode
        case enterPasscode
    }

    enum Action {
        case registration
        case logIn
        case logInBiometric
        case verifyAccess
        case verifyAccessBiometric
        case logout
        case setEnableBiometric
        case disabledBiometricUsingBiometric
        case changePasscode(oldPasscode: String)
        case changePasscodeByPassword
        case changePassword
    }

    struct State: Mutating {

        var displayState: DisplayState
        var hasBackButton: Bool
        var kind: PasscodeTypes.DTO.Kind
        var action: Action?
        var numbers: [PasscodeKind: [Int]]
        var passcode: String        
    }

    enum Event {
        case completedLogout
        case completedRegistration(AuthorizationAuthStatus)
        case completedChangePasscode(DomainLayer.DTO.Wallet)
        case completedChangePassword(DomainLayer.DTO.Wallet)
        case completedLogIn(AuthorizationAuthStatus)
        case completedVerifyAccess(AuthorizationVerifyAccessStatus)
        case tapLogInByPassword
        case handlerError(Error)
        case tapBack
        case tapLogoutButton
        case tapBiometricButton
        case completedInputNumbers([Int])
        case viewWillAppear
        case viewDidAppear
    }

    struct DisplayState: Mutating {

        enum Error {
            case incorrectPasscode
            case notFound
            case internetNotWorking
            case message(String)
        }

        var kind: PasscodeKind
        var numbers: [Int]
        var isLoading: Bool
        var isHiddenBackButton: Bool
        var isHiddenLogInByPassword: Bool
        var isHiddenLogoutButton: Bool
        var isHiddenBiometricButton: Bool
        var error: Error?
        var titleLabel: String
        var detailLabel: String?
    }
}

extension PasscodeTypes.PasscodeKind {

    func title() -> String {
        switch self {
        case .oldPasscode:
            return Localizable.Waves.Passcode.Label.Passcode.enter

        case .newPasscode:
            return Localizable.Waves.Passcode.Label.Passcode.create

        case .repeatPasscode:
            return Localizable.Waves.Passcode.Label.Passcode.verify

        case .enterPasscode:
            return Localizable.Waves.Passcode.Label.Passcode.enter
        }
    }
}
