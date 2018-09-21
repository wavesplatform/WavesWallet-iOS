//
//  WalletDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
extension DomainLayer.DTO {

    struct Wallet {
        let name: String
        let address: String
        let publicKey: String
        let secret: String
        let isLoggedIn: Bool
        let isBackedUp: Bool
        let hasBiometricEntrance: Bool
    }

    struct WalletSeed {
        let publicKey: String
        let seed: String
        let address: String
    }
}
