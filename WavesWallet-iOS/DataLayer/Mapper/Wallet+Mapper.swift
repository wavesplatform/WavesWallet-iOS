//
//  Wallet+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletEncryption {
    convenience init(wallet: DomainLayer.DTO.WalletEncryption) {
        self.init()
        self.publicKey = wallet.publicKey
        self.secret = wallet.kind.secret
        self.seedId = wallet.seedId
    }
}

extension DomainLayer.DTO.WalletEncryption {

    init(wallet: WalletEncryption) {
        self.publicKey = wallet.publicKey

        if let secret = wallet.secret {
            self.kind = .passcode(secret: secret)
        } else {
            self.kind = .none
        }
        self.seedId = wallet.seedId
    }
}

extension WalletItem {

    convenience init(wallet: DomainLayer.DTO.Wallet) {
        self.init()
        self.publicKey = wallet.publicKey
        self.name = wallet.name
        self.isLoggedIn = wallet.isLoggedIn
        self.isBackedUp = wallet.isBackedUp
        self.address = wallet.address
        self.hasBiometricEntrance = wallet.hasBiometricEntrance
        self.id = wallet.id
    }
}

extension DomainLayer.DTO.Wallet {

    init(wallet: WalletItem) {

        self.publicKey = wallet.publicKey
        self.name = wallet.name
        self.isLoggedIn = wallet.isLoggedIn
        self.isBackedUp = wallet.isBackedUp
        self.address = wallet.address        
        self.hasBiometricEntrance = wallet.hasBiometricEntrance
        self.id = wallet.id
    }
}

extension SeedItem {

    convenience init(seed: DomainLayer.DTO.WalletSeed) {
        self.init()
        self.publicKey = seed.publicKey
        self.address = seed.address
        self.seed = seed.seed
    }
}

extension DomainLayer.DTO.WalletSeed {

    init(seed: SeedItem) {
        self.publicKey = seed.publicKey
        self.seed = seed.seed
        self.address = seed.address
    }
}
