//
//  NetworkTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum NetworkSettingsTypes {
    enum DTO { }
}

extension NetworkSettingsTypes {

    enum Query {
        case confirmPassword(wallet: DomainLayer.DTO.Wallet, old: String, new: String)
    }

    struct State: Mutating {
        var wallet: DomainLayer.DTO.Wallet
        var accountSetting: DomainLayer.DTO.AccountSettings?        
        var displayState: DisplayState
        var query: Query?
        var isValidSpam: Bool        
    }

    enum Event {
        case readyView
        case setEnvironmets(Environment, DomainLayer.DTO.AccountSettings?)
        case handlerError(AuthorizationInteractorError)
        case inputSpam(String?)
        case switchSpam(Bool)
        case successSave
        case tapSetDeffault
        case tapSave
        case completedQuery
    }

    struct DisplayState: Mutating {

        var spamUrl: String
        var isSpam: Bool
        var isAppeared: Bool
        var isLoading: Bool
        var isEnabledSaveButton: Bool
        var isEnabledSetDeffaultButton: Bool
        var spamError: String?
    }
}
