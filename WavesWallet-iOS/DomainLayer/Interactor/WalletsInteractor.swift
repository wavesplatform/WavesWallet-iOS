//
//  WalletsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import CryptoSwift
import Foundation
import RxSwift

extension DomainLayer.DTO.Wallet {

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

enum WalletsInteractorError: Error {
    case invalid
}

protocol WalletsInteractorProtocol {

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]>
    func registerWallet(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<DomainLayer.DTO.Wallet>
    func deleteWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
}

private struct RegisterData {
    let id: String
    let keyForPassword: String
    let password: String
    let secret: String
}

final class WalletsInteractor: WalletsInteractorProtocol {

    private let localWalletRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private let localWalletSeedRepository: WalletSeedRepositoryProtocol = FactoryRepositories.instance.walletSeedRepositoryLocal
    private let remoteAuthenticationRepository: AuthenticationRepositoryProtocol = FactoryRepositories.instance.authenticationRepositoryRemote

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]> {
        return self.localWalletRepository.wallets()
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
            .catchError({ _ -> Observable<DomainLayer.DTO.Wallet> in
                Observable.error(WalletsInteractorError.invalid)
            })
            .share()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func deleteWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.never()
    }
}

fileprivate extension WalletsInteractor {

    func registerData(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<RegisterData> {

        return Observable.create { observer -> Disposable in

            let id = UUID().uuidString
            let keyForPassword = UUID().uuidString.sha512()
            let password = wallet.password.sha512()
            guard let secret: String = password.aesEncrypt(withKey: keyForPassword) else {
                observer.onError(WalletsInteractorError.invalid)
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
}
