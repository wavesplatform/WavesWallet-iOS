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

    struct State: Mutating {
        var displayState: DisplayState
    }

    enum Event {
        case viewDidAppear
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
        case language
        case backupPhrase
        case changePassword
        case changePasscode
        case biometric
        case network
        case rateApp
        case feedback
        case supportWavesplatform
        case info
    }

    struct Section: SectionBase {
         var rows: [Row]
    }
}
