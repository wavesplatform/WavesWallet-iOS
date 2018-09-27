//
//  AuthorizationInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import KeychainAccess
import LocalAuthentication

private enum Constants {
    static let service = "com.wavesplatform.wallets"
}

enum AuthorizationType {
    case passcode(String)
    case password(String)
    case biometric
}

enum AuthorizationInteractorError: Error {
    case fail
    case passcodeIncorrect
    case passwordIncorrect
    case permissionDenied
    case attemptsEnded
    case biometricDisable
}

protocol AuthorizationInteractorProtocol {

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?>
    func walletsLoggedIn() -> Observable<[DomainLayer.DTO.Wallet]>

    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    // Return AuthorizationInteractorError
    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet>

    func registerBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet>
    func removeBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet>

    func logout(publicKey: String) -> Observable<Bool>
    func logout() -> Observable<Bool>
    func revokeAuth() -> Observable<Bool>

    // Return AuthorizationInteractorError permissionDenied
    func authorizedWallet() -> Observable<DomainLayer.DTO.SignedWallet>
}


private final class SeedRepositoryMemory {

    private static var map: [String: DomainLayer.DTO.WalletSeed] = .init()
    //TODO: Change to OSSpinLockLock
    private let serialQueue = DispatchQueue(label: "authorization.mutex")

    func append(_ seed: DomainLayer.DTO.WalletSeed) {
        serialQueue.sync {
            SeedRepositoryMemory.map[seed.publicKey] = seed
        }
    }

    func remove(_ publicKey: String) {
        _ = serialQueue.sync {
            SeedRepositoryMemory.map.removeValue(forKey: publicKey)
        }
    }

    func seed(_ publicKey: String) -> DomainLayer.DTO.WalletSeed? {
        return serialQueue.sync {
            return SeedRepositoryMemory.map[publicKey]
        }
    }

    func hasSeed(_ publicKey: String) -> Bool {
        return serialQueue.sync {
            return SeedRepositoryMemory.map[publicKey] != nil
        }
    }

    func removeAll() {
        serialQueue.sync {
            SeedRepositoryMemory.map.removeAll()
        }
    }
}

final class AuthorizationInteractor: AuthorizationInteractorProtocol {

    private let localWalletRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private let localWalletSeedRepository: WalletSeedRepositoryProtocol = FactoryRepositories.instance.walletSeedRepositoryLocal
    private let remoteAuthenticationRepository: AuthenticationRepositoryProtocol = FactoryRepositories.instance.authenticationRepositoryRemote

    //TODO: Mutex
    private let seedRepositoryMemory: SeedRepositoryMemory = SeedRepositoryMemory()

    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {

        switch type {
        case .passcode(let passcode):
            return remoteAuthenticationRepository
                .auth(with: wallet.id, passcode: passcode)
                .flatMap { [weak self] keyForPassword -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.empty() }
                    guard let password: String = wallet.secret.aesDecrypt(withKey: keyForPassword) else { return Observable.empty() }

                    return owner.authWithPassword(password, wallet: wallet)
                }
                .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                    return Observable.error(owner.handlerError(error))
                })


        case .password(let password):
            
            return Crypto
                .rx
                .sha512(password)
                .flatMap { [weak self] password -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.empty() }
                    return owner.authWithPassword(password, wallet: wallet)
                }

        case .biometric:
            return authBiometric(wallet: wallet)
        }
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

    func authorizedWallet() -> Observable<DomainLayer.DTO.SignedWallet> {
        return lastWalletLoggedIn()
            .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.SignedWallet> in

                guard let owner = self else { return Observable.never() }
                guard let wallet = wallet else { return Observable.error(AuthorizationInteractorError.permissionDenied) }
                guard let seed = owner.seedRepositoryMemory.seed(wallet.publicKey) else { return Observable.error(AuthorizationInteractorError.permissionDenied) }
                return Observable.just(DomainLayer.DTO.SignedWallet.init(wallet: wallet,
                                                                         publicKey: PublicKeyAccount(publicKey: seed.publicKey),
                                                                         signingWallets: owner))
            })
    }

    func logout() -> Observable<Bool> {
        return walletsLoggedIn().flatMap(weak: self, selector: { $0.logout })
    }

    func revokeAuth() -> Observable<Bool> {

        return Observable.create({ [weak self] observer -> Disposable in
            self?.seedRepositoryMemory.removeAll()
            WalletManager.clearPrivateMemoryKey()
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        })
    }

    func logout(publicKey: String) -> Observable<Bool> {
        return Observable.create({ [weak self] observer -> Disposable in

            guard let owner = self else { return Disposables.create() }

            let disposable = owner
                .localWalletRepository
                .wallet(by: publicKey)
                .flatMap({ wallet -> Observable<Bool> in
                    let newWallet = wallet.mutate(transform: { $0.isLoggedIn = false })
                    return owner
                        .localWalletRepository
                        .saveWallet(newWallet)
                        .map { _ in true }
                })
                .subscribe(onNext: { completed in
                    observer.onNext(completed)
                    observer.onCompleted()
                })

            return Disposables.create([disposable])
        })
    }

    func registerBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {

        return auth(type: .passcode(passcode), wallet: wallet)
            .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .savePasscodeInKeychain(wallet: wallet, passcode: passcode)
                    .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                        guard let owner = self else { return Observable.never() }
                        return owner.setHasBiometricEntrance(wallet: wallet, hasBiometricEntrance: true)
                    })
            })
    }

    func removeBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {

        return auth(type: .passcode(passcode), wallet: wallet)
            .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .removePasscodeInKeychain(wallet: wallet)
                    .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                        guard let owner = self else { return Observable.never() }
                        return owner.setHasBiometricEntrance(wallet: wallet, hasBiometricEntrance: false)
                    })
            })
    }
}

private extension AuthorizationInteractor {

    private func removePasscodeInKeychain(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in

            let keychain = Keychain(service: Constants.service)
                .accessibility(.whenUnlocked)

            do {

                try keychain
                    .accessibility(.whenUnlocked, authenticationPolicy: AuthenticationPolicy.touchIDAny)
                    .remove(wallet.publicKey)

                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onError(AuthorizationInteractorError.biometricDisable)
            }

            return Disposables.create()
        }
    }

    private func savePasscodeInKeychain(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in

            let keychain = Keychain(service: Constants.service)
                .label("Waves wallet seeds")
                .accessibility(.whenUnlocked)

            do {

                try keychain
                    .authenticationPrompt("Authenticate to store encrypted wallet private key")
                    .accessibility(.whenUnlocked, authenticationPolicy: AuthenticationPolicy.touchIDAny)
                    .set(passcode, key: wallet.publicKey)

                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onError(AuthorizationInteractorError.biometricDisable)
            }

            return Disposables.create()
        }
    }

    private func authBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {

        return Observable<String>.create { observer -> Disposable in

            let keychain = Keychain(service: Constants.service)

            do {

                guard let passcode = try keychain
                    .authenticationPrompt("Authenticate to decrypt wallet private key and confirm your transaction")
                    .accessibility(.whenUnlocked, authenticationPolicy: AuthenticationPolicy.touchIDAny)
                    .get(wallet.publicKey) else
                {
                    observer.onError(AuthorizationInteractorError.biometricDisable)
                    return Disposables.create()
                }

                observer.onNext(passcode)
                observer.onCompleted()
            } catch _ {
                observer.onError(AuthorizationInteractorError.permissionDenied)
            }

            return Disposables.create()
        }
        .flatMap({ [weak self] passcode -> Observable<DomainLayer.DTO.Wallet> in
            guard let owner = self else { return Observable.never() }
            return owner.auth(type: .passcode(passcode), wallet: wallet)
        })
    }

    private func authWithPassword(_ password: String, wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {
        return localWalletSeedRepository
            .seed(for: wallet.address, publicKey: wallet.publicKey, password: password)
            .flatMap({ [weak self] seed -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.empty() }
                owner.seedRepositoryMemory.append(seed)

                
                var oldWallet = Wallet.init(name: wallet.name,
                                           publicKeyAccount: PublicKeyAccount.init(publicKey: Base58.decode(seed.publicKey)),
                                           isBackedUp: true)
                oldWallet.privateKey = PrivateKeyAccount(seedStr: seed.seed)
                WalletManager.currentWallet = oldWallet
                return owner.setIsLoggedIn(wallet: wallet)
            })
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    private func setIsLoggedIn(wallet: DomainLayer.DTO.Wallet,
                               isLoggedIn: Bool = true) -> Observable<DomainLayer.DTO.Wallet> {
        return localWalletRepository
            .wallets(specifications: .init(isLoggedIn: true))
            .flatMap({ [weak self] wallets -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.empty() }

                var newWallets = wallets.mutate(transform: { wallet in
                    wallet.isLoggedIn = false
                })
                let currentWallet = wallet.mutate(transform: { wallet in
                    wallet.isLoggedIn = isLoggedIn
                })

                newWallets.append(currentWallet)

                return owner
                    .localWalletRepository
                    .saveWallets(newWallets)
                    .map { _ in currentWallet }
            })
    }

    private func setHasBiometricEntrance(wallet: DomainLayer.DTO.Wallet, hasBiometricEntrance: Bool = true) -> Observable<DomainLayer.DTO.Wallet> {

        let newWallet = wallet.mutate(transform: { $0.hasBiometricEntrance = hasBiometricEntrance })

        return self
            .localWalletRepository
            .saveWallet(newWallet)
            .map { _ in newWallet }
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

// MARK: SigningWalletsProtocol
extension AuthorizationInteractor: SigningWalletsProtocol {

    func sign(input: [UInt8], kind: [SigningKind], publicKey: String) throws -> [UInt8] {

        guard let seed = seedRepositoryMemory.seed(publicKey) else { throw SigningWalletsError.notSigned }
        let privateKey = PrivateKeyAccount(seedStr: seed.seed)
        return Hash.sign(input, privateKey.privateKey)
    }
}
