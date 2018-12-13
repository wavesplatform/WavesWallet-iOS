//
//  ProfileTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ProfileTypes {
    enum ViewModel { }
}

extension ProfileTypes {

    enum Query: Hashable {
        case showAddressesKeys(wallet: DomainLayer.DTO.Wallet)
        case showAddressBook
        case showLanguage
        case showBackupPhrase(wallet: DomainLayer.DTO.Wallet)
        case showChangePassword(wallet: DomainLayer.DTO.Wallet)
        case showChangePasscode(wallet: DomainLayer.DTO.Wallet)
        case showNetwork(wallet: DomainLayer.DTO.Wallet)
        case showRateApp
        case showAlertForEnabledBiometric
        case showFeedback
        case showSupport
        case setEnabledBiometric(Bool, wallet: DomainLayer.DTO.Wallet)
        case setBackedUp(Bool)
        case logoutAccount
        case deleteAccount
    }

    struct State: Mutating {
        var query: Query?
        var wallet: DomainLayer.DTO.Wallet?
        var block: Int64?
        var displayState: DisplayState
    }

    enum Event {
        case viewDidAppear
        case viewDidDisappear
        case tapRow(ProfileTypes.ViewModel.Row)
        case setEnabledBiometric(Bool)
        case setBlock(Int64)
        case setWallet(DomainLayer.DTO.Wallet)
        case setBackedUp(Bool)
        case tapLogout
        case tapDelete
        case completedQuery
        case none
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

extension ProfileTypes.ViewModel {

    enum Row {
        case addressesKeys
        case addressbook
        case pushNotifications
        case language(Language)
        case backupPhrase(isBackedUp: Bool)
        case changePassword
        case changePasscode
        case biometricDisabled
        case biometric(isOn: Bool)
        case network
        case rateApp
        case feedback
        case supportWavesplatform
        case info(version: String, height: String?, isBackedUp: Bool)
    }

    struct Section: SectionBase, Mutating {

        enum Kind {
            case general
            case security
            case other
        }
        
        var rows: [Row]
        var kind: Kind
    }
}
