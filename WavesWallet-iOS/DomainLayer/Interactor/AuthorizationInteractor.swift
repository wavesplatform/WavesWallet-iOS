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
import RealmSwift

private enum Constants {
    static let service = "com.wavesplatform.wallets"
}

private extension DomainLayer.DTO.Wallet {

    init(id: String, secret: String, query: DomainLayer.DTO.WalletRegistation) {

        self.name = query.name
        self.address = query.privateKey.address
        self.publicKey = query.privateKey.getPublicKeyStr()
        self.secret = secret
        self.isLoggedIn = false
        self.isBackedUp = query.isBackedUp
        self.hasBiometricEntrance = false
        self.id = id
    }
}

private extension AuthorizationInteractor {

    func registerData(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<RegisterData> {

        return Observable.create { observer -> Disposable in

            let id = UUID().uuidString
            let keyForPassword = UUID().uuidString.sha512()
            let password = wallet.password.sha512()
            guard let secret: String = password.aesEncrypt(withKey: keyForPassword) else {
                observer.onError(AuthorizationInteractorError.fail)
                return Disposables.create()
            }

            observer.onNext(RegisterData(id: id,
                                         keyForPassword: keyForPassword,
                                         password: password,
                                         secret: secret))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func changePasscodeData(_ wallet: DomainLayer.DTO.Wallet, password: String) -> Observable<ChangePasscodeData> {

        return Observable.create { observer -> Disposable in

            let keyForPassword = UUID().uuidString.sha512()
            let password = password.sha512()
            guard let secret: String = password.aesEncrypt(withKey: keyForPassword) else {
                observer.onError(AuthorizationInteractorError.fail)
                return Disposables.create()
            }

            var newWallet = wallet
            newWallet.secret = secret

            observer.onNext(ChangePasscodeData(wallet: newWallet,
                                               keyForPassword: keyForPassword,
                                               password: password))

            observer.onCompleted()
            return Disposables.create()
        }
    }
}


private struct ChangePasscodeData {
    let wallet: DomainLayer.DTO.Wallet
    let keyForPassword: String
    let password: String
}


private struct RegisterData {
    let id: String
    let keyForPassword: String
    let password: String
    let secret: String
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

    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationBiometricStatus> {

        switch type {
        case .passcode(let passcode):

            let remote = authWithPasscode(passcode, wallet: wallet)
                .map { AuthorizationBiometricStatus.completed($0) }

            return Observable.merge(Observable.just(AuthorizationBiometricStatus.waiting), remote)

        case .password(let password):
            
            let remote = Crypto
                .rx
                .sha512(password)
                .flatMap { [weak self] password -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.empty() }
                    return owner.authWithPassword(password, wallet: wallet)
                }
                .map { AuthorizationBiometricStatus.completed($0) }

            return Observable.merge(Observable.just(AuthorizationBiometricStatus.waiting), remote)

        case .biometric:
            return authBiometric(wallet: wallet)
        }
    }

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?> {
        return walletsLoggedIn()
            .sweetDebug("Last Wallet walletsLoggedIn")
            .flatMap({ wallets -> Observable<DomainLayer.DTO.Wallet?> in
                return Observable.just(wallets.first)
            })
    }

    func walletsLoggedIn() -> Observable<[DomainLayer.DTO.Wallet]> {
        return localWalletRepository
            .wallets(specifications: .init(isLoggedIn: true))
            .catchError({ [weak self] error -> Observable<[DomainLayer.DTO.Wallet]> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
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
                                                                         privateKey: PrivateKeyAccount(seedStr: seed.seed),
                                                                         signingWallets: owner))
            })
    }

    func changePasscode(wallet: DomainLayer.DTO.Wallet, oldPasscode: String, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {
        return remoteAuthenticationRepository
            .changePasscode(with: wallet.id, oldPasscode: oldPasscode, passcode: passcode)
            .map { _ in wallet }
            .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.never() }
                return owner.reRegisterBiometric(wallet: wallet, passcode: passcode)
            })
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    func changePasscodeByPassword(wallet: DomainLayer.DTO.Wallet, passcode: String, password: String) -> Observable<DomainLayer.DTO.Wallet> {

        return self
            .changePasscodeData(wallet, password: password)
            .flatMap({ [weak self] data -> Observable<DomainLayer.DTO.Wallet> in

                guard let owner = self else { return Observable.never() }
                let wallet = data.wallet

                return owner.remoteAuthenticationRepository
                    .registration(with: wallet.id,
                                  keyForPassword: data.keyForPassword,
                                  passcode: passcode)
                    .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in

                        guard let owner = self else { return Observable.never() }
                        return owner.localWalletRepository.saveWallet(wallet)
                    })
                    .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in
                        guard let owner = self else { return Observable.never() }
                        return owner.reRegisterBiometric(wallet: wallet, passcode: passcode)
                    })
            })
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }
}


// MARK: Wallets methods
extension AuthorizationInteractor {

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]> {
        return self
            .localWalletRepository
            .wallets()
            .catchError({ [weak self] error -> Observable<[DomainLayer.DTO.Wallet]> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    func registerWallet(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<DomainLayer.DTO.Wallet> {

        return self.registerData(wallet)
            .flatMap({ [weak self] (data) -> Observable<DomainLayer.DTO.Wallet> in

                guard let owner = self else { return Observable.never() }

                return owner.remoteAuthenticationRepository.registration(with: data.id,
                                                                         keyForPassword: data.keyForPassword,
                                                                         passcode: wallet.passcode)
                    .flatMap { [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                        guard let owner = self else { return Observable.never() }
                        let model = DomainLayer.DTO.Wallet(id: data.id, secret: data.secret, query: wallet)

                        let saveSeed = owner
                            .localWalletSeedRepository
                            .saveSeed(for: .init(publicKey: wallet.privateKey.getPublicKeyStr(),
                                                 seed: wallet.privateKey.wordsStr,
                                                 address: wallet.privateKey.address),
                                      password: data.password)

                        let saveWallet = owner.localWalletRepository.saveWallet(model)
                        return saveSeed.flatMap { _ -> Observable<DomainLayer.DTO.Wallet> in
                            saveWallet
                        }
                }
            })
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func deleteWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.zip([localWalletRepository.removeWallet(wallet),
                               localWalletSeedRepository.deleteSeed(for: wallet.address)])
            .map { _ in true }
            .catchError({ [weak self] error -> Observable<Bool> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    func changeWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.never()
    }
}

// MARK: Logout methods

extension AuthorizationInteractor {

    func logout() -> Observable<DomainLayer.DTO.Wallet> {
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

    func logout(wallet publicKey: String) -> Observable<DomainLayer.DTO.Wallet> {
        return Observable.create({ [weak self] observer -> Disposable in

            guard let owner = self else { return Disposables.create() }

            let disposable = owner
                .localWalletRepository
                .wallet(by: publicKey)
                .flatMap({ wallet -> Observable<DomainLayer.DTO.Wallet> in
                    let newWallet = wallet.mutate(transform: { $0.isLoggedIn = false })
                    return owner
                        .localWalletRepository
                        .saveWallet(newWallet)
                })
                .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                    return Observable.error(owner.handlerError(error))
                })
                .subscribe(onNext: { completed in
                    observer.onNext(completed)
                    observer.onCompleted()
                })

            return Disposables.create([disposable])
        })
    }
}

// MARK: Biometric methods

extension AuthorizationInteractor {

    func registerBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationBiometricStatus> {

        let auth = authWithPasscode(passcode, wallet: wallet)
            .flatMap({ [weak self] wallet -> Observable<AuthorizationBiometricStatus>  in

                guard let owner = self else { return Observable.never() }

                let savePasscode = owner
                    .savePasscodeInKeychain(wallet: wallet, passcode: passcode)
                    .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                        guard let owner = self else { return Observable.never() }
                        return owner.setHasBiometricEntrance(wallet: wallet, hasBiometricEntrance: true)
                    })
                    .map { AuthorizationBiometricStatus.completed($0) }

                return Observable.merge(.just(AuthorizationBiometricStatus.detectBiometric), savePasscode)
            })

        return Observable.merge(.just(AuthorizationBiometricStatus.waiting), auth)
    }

    func unregisterBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationBiometricStatus> {

        let auth = authWithPasscode(passcode, wallet: wallet)
            .flatMap({ [weak self] status -> Observable<AuthorizationBiometricStatus> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .removePasscodeInKeychain(wallet: wallet)
                    .flatMap({ [weak self] _ -> Observable<AuthorizationBiometricStatus> in
                        guard let owner = self else { return Observable.never() }

                        let removeBiometric = owner
                            .setHasBiometricEntrance(wallet: wallet, hasBiometricEntrance: false)
                            .map { AuthorizationBiometricStatus.completed($0) }

                        return Observable.merge(.just(AuthorizationBiometricStatus.detectBiometric), removeBiometric)
                    })
            })

        return Observable.merge(.just(AuthorizationBiometricStatus.waiting), auth)
    }

    func unregisterBiometricUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationBiometricStatus> {

        let passcode = passcodeFromKeychain(wallet: wallet)
            .flatMap { [weak self] passcode -> Observable<AuthorizationBiometricStatus> in
                guard let owner = self else { return Observable.never() }
                return owner.unregisterBiometric(wallet: wallet, passcode: passcode)
        }

        return Observable.merge(.just(AuthorizationBiometricStatus.detectBiometric), passcode)
    }

    private func reRegisterBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {

        if wallet.hasBiometricEntrance {
            return registerBiometric(wallet: wallet, passcode: passcode)
                .filter({ status -> Bool in
                    if case .completed = status {
                        return true
                    } else {
                        return false
                    }
                })
                .flatMap({ status -> Observable<DomainLayer.DTO.Wallet> in
                    if case .completed(let wallet) = status {
                        return Observable.just(wallet)
                    }
                    return Observable.empty()
                })
                .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                    guard let owner = self else { return Observable.never() }
                    var newWallet = wallet
                    newWallet.hasBiometricEntrance = false
                    return owner.localWalletRepository.saveWallet(newWallet)
                })
        } else {
            return Observable.just(wallet)
        }
    }
}

// MARK: Keychain methods

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
            } catch let error {
                observer.onError(AuthorizationInteractorError.biometricDisable)
            }

            return Disposables.create()
        }
    }

    private func passcodeFromKeychain(wallet: DomainLayer.DTO.Wallet) -> Observable<String> {

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
    }
}

// MARK: Auth methods

private extension AuthorizationInteractor {

    private func authBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationBiometricStatus> {

        let auth = passcodeFromKeychain(wallet: wallet)
            .flatMap({ [weak self] passcode -> Observable<AuthorizationBiometricStatus> in
                guard let owner = self else { return Observable.never() }
                return owner.auth(type: .passcode(passcode), wallet: wallet)
            })

        return Observable.merge(Observable.just(AuthorizationBiometricStatus.detectBiometric), auth)
    }

    private func getPasswordByPasscode(_ passcode: String, wallet: DomainLayer.DTO.Wallet) -> Observable<String> {

        return remoteAuthenticationRepository
            .auth(with: wallet.id, passcode: passcode)
            .sweetDebug("getPasswordByPasscode")
            .flatMap { keyForPassword -> Observable<String> in
                guard let password: String = wallet.secret.aesDecrypt(withKey: keyForPassword) else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.just(password)
            }
            .catchError({ [weak self] error -> Observable<String> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    private func authWithPasscode(_ passcode: String, wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {

        return getPasswordByPasscode(passcode, wallet: wallet)
            .flatMap { [weak self] password -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.empty() }
                return owner.authWithPassword(password, wallet: wallet)
            }
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    private func authWithPassword(_ password: String, wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {
        return localWalletSeedRepository
            .seed(for: wallet.address, publicKey: wallet.publicKey, password: password)
            .sweetDebug("Local Seed")
            .flatMap({ [weak self] seed -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.empty() }
                owner.seedRepositoryMemory.append(seed)

                owner.setWalletRealmConfig(wallet: wallet)
                var oldWallet = Wallet.init(name: wallet.name,
                                            publicKeyAccount: PublicKeyAccount.init(publicKey: Base58.decode(seed.publicKey)),
                                            isBackedUp: wallet.isBackedUp)
                oldWallet.privateKey = PrivateKeyAccount(seedStr: seed.seed)
                WalletManager.currentWallet = oldWallet
                return owner.setIsLoggedIn(wallet: wallet)
            })
            .sweetDebug("authWithPassword")
            .catchError({ [weak self] error -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.error(AuthorizationInteractorError.fail) }
                return Observable.error(owner.handlerError(error))
            })
    }

    func setWalletRealmConfig(wallet: DomainLayer.DTO.Wallet) {

        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(wallet.address).realm")
          Realm.Configuration.defaultConfiguration = config
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

    private func logout(_ wallets: [DomainLayer.DTO.Wallet]) -> Observable<DomainLayer.DTO.Wallet> {
        return Observable.merge(wallets.map { logout(wallet: $0.publicKey) })
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
