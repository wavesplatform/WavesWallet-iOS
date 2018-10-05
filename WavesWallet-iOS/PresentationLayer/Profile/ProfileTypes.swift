//
//  ProfileTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ProfileTypes {
    enum DTO { }
    enum ViewModel { }
}

extension ProfileTypes.DTO {

}

extension ProfileTypes {

    enum Query: Hashable {
        case showAddressesKeys
        case showAddressBook
        case showLanguage
        case showBackupPhrase
        case showChangePassword
        case showChangePasscode
        case showNetwork
        case showRateApp
        case showFeedback
        case showSupport
        case setEnabledBiometric(Bool)        
        case tapLogout
        case tapDelete
    }

    struct State: Mutating {
        var displayState: DisplayState
    }

    enum Event {
        case viewDidAppear
        case tapRow(ProfileTypes.ViewModel.Row)
        case setEnabledBiometric(Bool)
        case tapLogout
        case tapDelete
    }

    struct DisplayState: Mutating, DataSourceProtocol {
        var sections: [ViewModel.Section]
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
        case biometric(isOn: Bool)
        case network
        case rateApp
        case feedback
        case supportWavesplatform
        case info(version: String, height: String?)
    }

    struct Section: SectionBase {

        enum Kind {
            case general
            case security
            case other
        }
        
        var rows: [Row]
        var kind: Kind
    }
}
