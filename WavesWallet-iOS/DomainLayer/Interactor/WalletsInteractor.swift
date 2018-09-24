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

final class WalletsInteractor: WalletsInteractorProtocol {

    private let localWalletRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private let localWalletSeedRepository: WalletSeedRepositoryProtocol = FactoryRepositories.instance.walletSeedRepositoryLocal
    private let remoteAuthenticationRepository: AuthenticationRepositoryProtocol = FactoryRepositories.instance.authenticationRepositoryRemote

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]> {
        return self.localWalletRepository.wallets()
    }

    func registerWallet(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<DomainLayer.DTO.Wallet> {

        let id = UUID().uuidString
        let keyForPassword = UUID().uuidString.sha512()

        guard let secret: String = wallet.password.sha512().aesEncrypt(withKey: keyForPassword) else { return Observable.error(WalletsInteractorError.invalid) }

        return self.remoteAuthenticationRepository.registration(with: id,
                                                                keyForPassword: keyForPassword,
                                                                passcode: wallet.passcode)
            .flatMap { [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else { return Observable.never() }
                let model = DomainLayer.DTO.Wallet(id: id, secret: secret, query: wallet)

                let saveSeed = owner.localWalletSeedRepository.saveSeed(for: .init(publicKey: wallet.privateKey.getPublicKeyStr(),
                                                                                   seed: wallet.privateKey.wordsStr,
                                                                                   address: wallet.privateKey.address),
                                                                        password: wallet.password.sha512())

                let saveWallet = owner.localWalletRepository.saveWallet(model)
                return saveSeed.flatMap({ _ -> Observable<DomainLayer.DTO.Wallet> in
                    return saveWallet
                })
            }
            .catchError({ _ -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(WalletsInteractorError.invalid)
            })
            .share()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func deleteWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.never()
    }
}
