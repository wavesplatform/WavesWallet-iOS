//
//  WalletDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
extension DomainLayer.DTO {

    struct Wallet: Mutating, Hashable {
        var name: String
        let address: String
        let publicKey: String
        var isLoggedIn: Bool
        var isBackedUp: Bool
        var hasBiometricEntrance: Bool
        let id: String
    }

    struct WalletEncryption: Mutating {

        enum Kind {
            case passcode(secret: String)
            case none

            var secret: String? {
                switch self {
                case .passcode(let secret):
                    return secret
                default:
                    return nil
                }
            }
        }

        let publicKey: String
        var kind: Kind
        var seedId: String
    }

    struct WalletSeed {
        let publicKey: String
        let seed: String
        let address: String
    }

    struct WalletRegistation {
        let name: String
        let address: String
        let privateKey: PrivateKeyAccount
        let isBackedUp: Bool
        let password: String
        let passcode: String
    }

    final class SignedWallet {

        let wallet: DomainLayer.DTO.Wallet
        let publicKey: PublicKeyAccount
        let privateKey: PrivateKeyAccount
        let seed: WalletSeed

        var address: String {
            return wallet.address
        }

        init(wallet: Wallet,
             seed: WalletSeed) {
            
            self.seed = seed
            self.wallet = wallet            
            self.publicKey = PublicKeyAccount(publicKey: seed.publicKey)
            self.privateKey = PrivateKeyAccount(seedStr: seed.seed)
        }

        func sign(input: [UInt8], kind: [SigningKind]) throws -> [UInt8] {
            let privateKey = PrivateKeyAccount(seedStr: seed.seed)
            return Hash.sign(input, privateKey.privateKey)
        }
        
        var seedWords: [String] {
            return seed.seed.split(separator: " ").map { "\($0)" }
        }
    }
}
