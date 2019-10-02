//
//  MigrateAccountTypes.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/25/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

enum MigrateAccountsTypes {
    
    enum ViewModel {}
    enum DTO {}
}

extension MigrateAccountsTypes {

    enum Event {
        case setWallets([DomainLayer.DTO.Wallet])
        case unlockWallet(DomainLayer.DTO.Wallet)
    }
    
    enum Action {
        case none
        case loadWallets
        case update
    }
    
    struct State {
        var action: Action
        var wallets: [DTO.UIWallet]
        var sections: [ViewModel.Section]
    }
}

extension MigrateAccountsTypes.DTO {
    
    struct UIWallet {
        let wallet: DomainLayer.DTO.Wallet
        let isLock: Bool
    }
}

extension MigrateAccountsTypes.ViewModel {
   
    struct Section {
        enum Kind {
            case title
            case unlocked
            case locked
        }
        
        var kind: Kind
        var rows: [Row]
    }
    
    enum Row {
        case title
        case unlock(DomainLayer.DTO.Wallet)
        case lock(DomainLayer.DTO.Wallet)
    }
}
