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

//protocol SigningDataInteractorProtocol {
//    func sign(input: [UInt8]) -> [UInt8]
//}
//
//final class SigningDataInteractor: SigningDataInteractorProtocol {
//
//    private let privateKey: PrivateKeyAccount
//
//    func sign(input: [UInt8]) -> [UInt8] {
//        return .init()
//    }
//}

enum AuthorizationInteractorError: Error {
    case fail
    case passcodeIncorrect
    case passwordIncorrect
    case permissionDenied
    case attemptsEnded
}

protocol AuthorizationInteractorProtocol {

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?>
    func walletsLoggedIn() -> Observable<[DomainLayer.DTO.Wallet]>

    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
    func logout(publicKey: String) -> Observable<Bool>
    func logout() -> Observable<Bool>
//    func sign(input: [UInt8])
}


private final class SeedRepositoryMemory {

    private static var map: [String: DomainLayer.DTO.WalletSeed] = .init()

    func append(_ seed: DomainLayer.DTO.WalletSeed) {
        SeedRepositoryMemory.map[seed.publicKey] = seed
    }

    func remove(_ publicKey: String) {
        SeedRepositoryMemory.map.removeValue(forKey: publicKey)
    }

    func seed(_ publicKey: String) -> DomainLayer.DTO.WalletSeed? {
        return SeedRepositoryMemory.map[publicKey]
    }

    func hasSeed(_ publicKey: String) -> Bool {
        return seed(publicKey) != nil
    }

    func removeAll() {
        SeedRepositoryMemory.map.removeAll()
    }
}

final class AuthorizationInteractor: AuthorizationInteractorProtocol {

    private let localWalletRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private let localWalletSeedRepository: WalletSeedRepositoryProtocol = FactoryRepositories.instance.walletSeedRepositoryLocal
    private let remoteAuthenticationRepository: AuthenticationRepositoryProtocol = FactoryRepositories.instance.authenticationRepositoryRemote
    private let seedRepositoryMemory: SeedRepositoryMemory = SeedRepositoryMemory()

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
                .catchError({ [weak self] error -> Observable<Bool> in
                    guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                    return Observable.error(owner.handlerError(error))
                })


        case .password(let password):
            return authWithPassword(password, wallet: wallet)
                .catchError({ [weak self] error -> Observable<Bool> in
                    guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                    return Observable.error(owner.handlerError(error))
                })

        case .biometric:
            break
        }

        return Observable.never()
    }

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?> {
        return walletsLoggedIn()
            .flatMap({ wallets -> Observable<DomainLayer.DTO.Wallet?> in
                return Observable.just(wallets.first)
            })
    }

    func walletsLoggedIn() -> Observable<[DomainLayer.DTO.Wallet]> {
        return localWalletRepository
            .wallets(specifications: .init(isLoggedIn: true))
    }

    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.just(seedRepositoryMemory.hasSeed(wallet.publicKey))
    }


    func logout() -> Observable<Bool> {
        return walletsLoggedIn().flatMap(weak: self, selector: { $0.logout })
    }

    func logout(publicKey: String) -> Observable<Bool> {
        return Observable.create({ [weak self] observer -> Disposable in

            self?.seedRepositoryMemory.remove(publicKey)

            observer.onNext(true)
            observer.onCompleted()

            return Disposables.create()
        })
    }
}

private extension AuthorizationInteractor {

    private func authWithPassword(_ password: String, wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return localWalletSeedRepository
            .seed(for: wallet.address, publicKey: wallet.publicKey, password: password)
            .flatMap({ [weak self] seed -> Observable<Bool> in
                guard let owner = self else { return Observable.empty() }
                owner.seedRepositoryMemory.append(seed)
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

    private func logout(_ wallets: [DomainLayer.DTO.Wallet]) -> Observable<Bool> {
        return Observable.merge(wallets.map { logout(publicKey: $0.publicKey) })
    }

    private func handlerError(_ error: Error) -> AuthorizationInteractorError {

        switch error {
        case let error as AuthenticationRepositoryError:
            switch error {
            case .attemptsEnded:
                return AuthorizationInteractorError.attemptsEnded

            case .fail:
                return AuthorizationInteractorError.fail

            case .passcodeIncorrect:
                return AuthorizationInteractorError.passcodeIncorrect

            case .permissionDenied:
                return AuthorizationInteractorError.permissionDenied
            }

        case let error as WalletSeedRepositoryError:
            switch error {
            case .permissionDenied:
                return  AuthorizationInteractorError.passwordIncorrect

            case .fail:
                return AuthorizationInteractorError.fail
            }

        default:
            break
        }

        return AuthorizationInteractorError.fail
    }
}
