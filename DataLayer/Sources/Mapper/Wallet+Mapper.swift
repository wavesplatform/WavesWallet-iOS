//
//  Wallet+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

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
        
        var kind: DomainLayer.DTO.WalletEncryption.Kind! = nil
        
        if let secret = wallet.secret {
            kind = .passcode(secret: secret)
        } else {
            kind = .none
        }
        
        self.init(publicKey: wallet.publicKey,
                  kind: kind,
                  seedId: wallet.seedId)
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
        self.isNeedShowWalletCleanBanner = wallet.isNeedShowWalletCleanBanner
    }
}

extension DomainLayer.DTO.Wallet {

    init(wallet: WalletItem) {

        self.init(name: wallet.name,
                  address: wallet.address,
                  publicKey: wallet.publicKey,
                  isLoggedIn: wallet.isLoggedIn,
                  isBackedUp: wallet.isBackedUp,
                  hasBiometricEntrance: wallet.hasBiometricEntrance,
                  id: wallet.id,
                  isNeedShowWalletCleanBanner: wallet.isNeedShowWalletCleanBanner)
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
        
        self.init(publicKey: seed.publicKey,
                  seed: seed.seed,
                  address: seed.address)
    }
}
