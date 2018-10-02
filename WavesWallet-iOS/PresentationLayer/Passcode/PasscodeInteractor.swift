//
//  NewAccountPasscodeInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol PasscodeInteractorProtocol {
    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<DomainLayer.DTO.Wallet>
    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet>
    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
    func logInBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet>
}

enum PasscodeInteractorError: Error {
    case fail
    case passcodeIncorrect
    case permissionDenied
    case attemptsEnded
}

final class PasscodeInteractor: PasscodeInteractorProtocol {

    private let walletsInteractor: WalletsInteractorProtocol = FactoryInteractors.instance.wallets
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {

        let query = DomainLayer.DTO.WalletRegistation.init(name: account.name,
                                               address: account.privateKey.address,
                                               privateKey: account.privateKey,
                                               isBackedUp: !account.needBackup,
                                               password: account.password,
                                               passcode: passcode)

        return walletsInteractor.registerWallet(query)
            .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in
                guard let owner = self else {  return Observable.empty() }
                return owner.authorizationInteractor.auth(type: .passcode(passcode), wallet: wallet)
            })
            .catchError(weak: self, handler: { (owner, error) -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(owner.handlerError(error))
            })            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logInBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {
        return authorizationInteractor
            .auth(type: .biometric, wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {
        return authorizationInteractor
            .auth(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return authorizationInteractor.logout(publicKey: wallet.publicKey)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    private func handlerError(_ error: Error) -> PasscodeInteractorError {

        switch error {
        case let authError as AuthorizationInteractorError:
            switch authError {
            case .attemptsEnded:
                return PasscodeInteractorError.attemptsEnded

            case .passcodeIncorrect:
                return PasscodeInteractorError.passcodeIncorrect

            case .permissionDenied:
                return PasscodeInteractorError.permissionDenied
            default:
                return PasscodeInteractorError.fail
            }

        default:
            return PasscodeInteractorError.fail
        }        
    }
}
