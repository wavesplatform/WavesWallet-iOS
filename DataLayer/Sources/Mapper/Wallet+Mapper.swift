//
//  Wallet+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

extension WalletEncryption {
    convenience init(wallet: DomainWalletEncryption) {
        self.init()
        self.publicKey = wallet.publicKey
        self.secret = wallet.kind.secret
        self.seedId = wallet.seedId
    }
}

extension DomainWalletEncryption {
    init(wallet: WalletEncryption) {
        
        var kind: DomainWalletEncryption.Kind = .none
        
        if let secret = wallet.secret {
            kind = .passcode(secret: secret)
        }
        
        self.init(publicKey: wallet.publicKey,
                  kind: kind,
                  seedId: wallet.seedId)
    }
}

extension WalletItem {

    public convenience init(wallet: Wallet) {
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

extension Wallet {

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

    public convenience init(seed: WalletSeed) {
        self.init()
        self.publicKey = seed.publicKey
        self.address = seed.address
        self.seed = seed.seed
    }
}

extension WalletSeed {

    init(seed: SeedItem) {
        self.init(publicKey: seed.publicKey,
                  seed: seed.seed,
                  address: seed.address)
    }
}
