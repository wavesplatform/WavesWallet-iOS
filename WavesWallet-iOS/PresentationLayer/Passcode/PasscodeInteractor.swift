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
    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<Bool>
    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<Bool>
    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
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

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<Bool> {

        let query = DomainLayer.DTO.WalletRegistation.init(name: account.name,
                                               address: account.privateKey.address,
                                               privateKey: account.privateKey,
                                               isBackedUp: !account.needBackup,
                                               password: account.password,
                                               passcode: passcode)

        return walletsInteractor.registerWallet(query)
            .flatMap({ [weak self] wallet -> Observable<Bool> in
                guard let owner = self else {  return Observable.empty() }
                return owner.authorizationInteractor.auth(type: .passcode(passcode), wallet: wallet)
            })
            .catchError(weak: self, handler: { (owner, error) -> Observable<Bool> in
                return Observable.error(owner.handlerError(error))
            })
            .share()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<Bool> {
        return authorizationInteractor
            .auth(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<Bool> in
                return Observable.error(owner.handlerError(error))
            })
    }

    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return authorizationInteractor.logout(publicKey: wallet.publicKey)
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
