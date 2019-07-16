//
//  WalletDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import Extensions

public extension DomainLayer.DTO {

    struct Wallet: Mutating, Hashable {
        public var name: String
        public let address: String
        public let publicKey: String
        public var isLoggedIn: Bool
        public var isBackedUp: Bool
        public var hasBiometricEntrance: Bool
        public let id: String
        public var isNeedShowWalletCleanBanner: Bool

        public init(name: String, address: String, publicKey: String, isLoggedIn: Bool, isBackedUp: Bool, hasBiometricEntrance: Bool, id: String, isNeedShowWalletCleanBanner: Bool) {
            self.name = name
            self.address = address
            self.publicKey = publicKey
            self.isLoggedIn = isLoggedIn
            self.isBackedUp = isBackedUp
            self.hasBiometricEntrance = hasBiometricEntrance
            self.id = id
            self.isNeedShowWalletCleanBanner = isNeedShowWalletCleanBanner
        }
    }

    struct WalletEncryption: Mutating {

        public enum Kind {
            case passcode(secret: String)
            case none

            public var secret: String? {
                switch self {
                case .passcode(let secret):
                    return secret
                default:
                    return nil
                }
            }
        }

        public let publicKey: String
        public var kind: Kind
        public var seedId: String

        public init(publicKey: String, kind: Kind, seedId: String) {
            self.publicKey = publicKey
            self.kind = kind
            self.seedId = seedId
        }
    }

    struct WalletSeed {
        public let publicKey: String
        public let seed: String
        public let address: String

        public init(publicKey: String, seed: String, address: String) {
            self.publicKey = publicKey
            self.seed = seed
            self.address = address
        }
    }

    struct WalletRegistation {
        public let name: String
        public let address: String
        public let privateKey: PrivateKeyAccount
        public let isBackedUp: Bool
        public let password: String
        public let passcode: String

        public init(name: String, address: String, privateKey: PrivateKeyAccount, isBackedUp: Bool, password: String, passcode: String) {
            self.name = name
            self.address = address
            self.privateKey = privateKey
            self.isBackedUp = isBackedUp
            self.password = password
            self.passcode = passcode
        }
    }

    final class SignedWallet {

        public let wallet: DomainLayer.DTO.Wallet
        public let publicKey: PublicKeyAccount
        public let privateKey: PrivateKeyAccount
        public let seed: WalletSeed

        public init(wallet: DomainLayer.DTO.Wallet, publicKey: PublicKeyAccount, privateKey: PrivateKeyAccount, seed: WalletSeed) {
            self.wallet = wallet
            self.publicKey = publicKey
            self.privateKey = privateKey
            self.seed = seed
        }

        public var address: String {
            return wallet.address
        }

        public init(wallet: Wallet,
             seed: WalletSeed) {
            
            self.seed = seed
            self.wallet = wallet            
            self.publicKey = PublicKeyAccount(publicKey: seed.publicKey)
            self.privateKey = PrivateKeyAccount(seedStr: seed.seed)
        }

        public func sign(input: [UInt8], kind: [SigningKind]) throws -> [UInt8] {
            let privateKey = PrivateKeyAccount(seedStr: seed.seed)
            return Hash.sign(input, privateKey.privateKey)
        }
        
        public var seedWords: [String] {
            return seed.seed.split(separator: " ").map { "\($0)" }
        }
    }
}
