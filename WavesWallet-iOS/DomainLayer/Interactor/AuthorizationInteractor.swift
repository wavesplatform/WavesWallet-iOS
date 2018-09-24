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

protocol SigningProtocol {
    func sign() -> Void
}

protocol AuthorizationInteractorProtocol {
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
            
        }

        return Observable.never()
    }

    func logout() -> Void {

    }
}
