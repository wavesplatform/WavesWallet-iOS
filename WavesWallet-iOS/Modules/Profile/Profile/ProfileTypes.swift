//
//  ProfileTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

enum ProfileTypes {
    enum ViewModel { }
}

extension ProfileTypes {

    enum Query: Hashable {
        case showAddressesKeys(wallet: Wallet)
        case showAddressBook
        case showLanguage
        case showBackupPhrase(wallet: Wallet)
        case showChangePassword(wallet: Wallet)
        case showChangePasscode(wallet: Wallet)
        case showNetwork(wallet: Wallet)
        case showRateApp
        case showAlertForEnabledBiometric
        case showFeedback
        case showSupport
        case setEnabledBiometric(Bool, wallet: Wallet)
        case setBackedUp(Bool)
        case logoutAccount
        case deleteAccount
        case updatePushNotificationsSettings
        case registerPushNotifications
        case openFaq
        case openTermOfCondition
        case didTapDebug
    }

    struct State: Mutating {
        var query: Query?
        var wallet: Wallet?
        var block: Int64?
        var displayState: DisplayState
        var isActivePushNotifications: Bool
    }

    enum Event {
        case viewDidAppear
        case viewDidDisappear
        case tapRow(ProfileTypes.ViewModel.Row)
        case setEnabledBiometric(Bool)
        case setBlock(Int64)
        case setWallet(Wallet)
        case setBackedUp(Bool)
        case tapLogout
        case tapDelete
        case completedQuery
        case setPushNotificationsSettings(Bool)
        case updatePushNotificationsSettings
        case didTapDebug
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
        case pushNotifications(isActive: Bool)
        case language(Language)
        case backupPhrase(isBackedUp: Bool)
        case changePassword
        case changePasscode
        case biometricDisabled
        case biometric(isOn: Bool)
        case network
        case exchangeTitle
        case rateApp
        case feedback
        case faq
        case termOfConditions
        case supportWavesplatform
        case socialNetwork
        case info(version: String, height: String?, isBackedUp: Bool)
    }

    struct Section: SectionProtocol, Mutating {

        enum Kind {
            case general
            case security
            case other
        }
        
        var rows: [Row]
        var kind: Kind
    }
}
