//
//  MyAccountsTypes.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/1/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

enum MyAccountsTypes {
    
    enum ViewModel {}
    enum DTO {}
}

extension MyAccountsTypes {
    
    enum Event {
        case setWallets([DomainLayer.DTO.Wallet])
        case activateWallet(DomainLayer.DTO.Wallet)
        case unlockWallet(DomainLayer.DTO.Wallet)
        case editWallet(DomainLayer.DTO.Wallet)
        case deleteWallet(DomainLayer.DTO.Wallet)
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

extension MyAccountsTypes.DTO {
    
    struct UIWallet {
        let wallet: DomainLayer.DTO.Wallet
        let isLock: Bool
    }
}

extension MyAccountsTypes.ViewModel {
    
    struct Section {
        enum Kind {
            case unlocked
            case locked
        }
        
        var kind: Kind
        var rows: [Row]
    }
    
    enum Row {
        case selected(DomainLayer.DTO.Wallet)
        case unlock(DomainLayer.DTO.Wallet)
        case lock(DomainLayer.DTO.Wallet)
    }
}
