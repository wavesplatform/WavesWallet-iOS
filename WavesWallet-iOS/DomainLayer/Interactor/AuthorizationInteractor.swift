//
//  AuthorizationInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum AuthorizationType {
    case passcode(String)
    case password(String)
    case biometric
}

protocol SigningDataInteractorProtocol {
    func sign(input: [UInt8]) -> [UInt8]
}

final class SigningDataInteractor: SigningDataInteractorProtocol {

    private let privateKey: PrivateKeyAccount

    func sign(input: [UInt8]) -> [UInt8] {
        return .init()
    }
}

protocol AuthorizationInteractorProtocol {

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?>
    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
    func logout() -> Void
}

final class AuthorizationInteractor: AuthorizationInteractorProtocol {

    private let localWalletRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private let localWalletSeedRepository: WalletSeedRepositoryProtocol = FactoryRepositories.instance.walletSeedRepositoryLocal
    private let remoteAuthenticationRepository: AuthenticationRepositoryProtocol = FactoryRepositories.instance.authenticationRepositoryRemote

    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {

        switch type {
        case .passcode(let passcode):

            return remoteAuthenticationRepository
                .auth(with: wallet.id, passcode: passcode)
                .flatMap { [weak self] keyForPassword -> Observable<Bool> in
                    guard let owner = self else { return Observable.empty() }
                    guard let password: String = wallet.secret.aesDecrypt(withKey: keyForPassword) else { return Observable.empty() }

                    return owner.authWithPassword(password, wallet: wallet)
                }


        case .password(let password):
            break

        case .biometric:
            break
        }

        return Observable.never()
    }

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?> {
        return localWalletRepository
            .wallets(specifications: .init(isLoggedIn: true))
            .flatMap({ wallets -> Observable<DomainLayer.DTO.Wallet?> in
                return Observable.just(wallets.first)
            })
    }


    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.never()
    }

    func logout() -> Void {

    }

    private func authWithPassword(_ password: String, wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return localWalletSeedRepository
            .seed(for: wallet.id, publicKey: wallet.publicKey, password: password)
            .flatMap({ [weak self] seed -> Observable<Bool> in
                guard let owner = self else { return Observable.empty() }
                print(seed)

                return owner.setIsLoggedIn(wallet: wallet)
            })
    }

    private func setIsLoggedIn(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return localWalletRepository
            .wallets(specifications: .init(isLoggedIn: true))
            .flatMap({ [weak self] wallets -> Observable<Bool> in
                guard let owner = self else { return Observable.empty() }

                var newWallets = wallets.mutate(transform: { wallet in
                    wallet.isLoggedIn = false
                })
                let currentWallet = wallet.mutate(transform: { wallet in
                    wallet.isLoggedIn = true
                })

                newWallets.append(currentWallet)

                return owner
                    .localWalletRepository
                    .saveWallets(newWallets)
                    .map { _ in true }
            })
    }
}

