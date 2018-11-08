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
        let name: String
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

        private weak var signingWallets: SigningWalletsProtocol?

        init(wallet: Wallet,
             seed: WalletSeed,
             signingWallets: SigningWalletsProtocol) {
            
            self.seed = seed
            self.wallet = wallet
            self.signingWallets = signingWallets
            self.publicKey = PublicKeyAccount(publicKey: seed.publicKey)
            self.privateKey = PrivateKeyAccount(seedStr: seed.seed)
        }

        func sign(input: [UInt8], kind: [SigningKind]) throws -> [UInt8] {
            guard let signingWallets = signingWallets else { throw SigningWalletsError.accessDenied }
            return try signingWallets.sign(input: input, kind: kind, publicKey: wallet.publicKey)
        }
    }
}
