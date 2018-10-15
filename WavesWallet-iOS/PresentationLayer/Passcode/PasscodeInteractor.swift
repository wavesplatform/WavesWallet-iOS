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

    func changePasscodeByPassword(wallet: DomainLayer.DTO.Wallet, passcode: String, password: String) -> Observable<DomainLayer.DTO.Wallet>
    func changePasscode(wallet: DomainLayer.DTO.Wallet, oldPasscode: String, passcode: String) -> Observable<DomainLayer.DTO.Wallet>

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<AuthorizationAuthStatus>

    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationAuthStatus>
    func logInBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationAuthStatus>
    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    func setEnableBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String, isOn: Bool) -> Observable<AuthorizationAuthStatus>
    func disabledBiometricUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationAuthStatus>

    func verifyAccessUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationVerifyAccessStatus>
    func verifyAccess(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationVerifyAccessStatus>
}

enum PasscodeInteractorError: Error {
    case fail
    case passcodeIncorrect
    case permissionDenied
    case attemptsEnded
}

final class PasscodeInteractor: PasscodeInteractorProtocol {


    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    func changePasscode(wallet: DomainLayer.DTO.Wallet, oldPasscode: String, passcode: String) -> Observable<DomainLayer.DTO.Wallet> {
        return authorizationInteractor
            .changePasscode(wallet: wallet, oldPasscode: oldPasscode, passcode: passcode)
            .catchError(weak: self, handler: { (owner, error) -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(owner.handlerError(error))
            })            
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func changePasscodeByPassword(wallet: DomainLayer.DTO.Wallet, passcode: String, password: String) -> Observable<DomainLayer.DTO.Wallet> {
        return authorizationInteractor
            .changePasscodeByPassword(wallet: wallet, passcode: passcode, password: password)
            .catchError(weak: self, handler: { (owner, error) -> Observable<DomainLayer.DTO.Wallet> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<AuthorizationAuthStatus> {

        let query = DomainLayer.DTO.WalletRegistation.init(name: account.name,
                                               address: account.privateKey.address,
                                               privateKey: account.privateKey,
                                               isBackedUp: !account.needBackup,
                                               password: account.password,
                                               passcode: passcode)

        return authorizationInteractor.registerWallet(query)
            .flatMap({ [weak self] wallet -> Observable<AuthorizationAuthStatus> in
                guard let owner = self else {  return Observable.empty() }
                return owner.authorizationInteractor.auth(type: .passcode(passcode), wallet: wallet)
            })
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationAuthStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logInBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationAuthStatus> {
        return authorizationInteractor
            .auth(type: .biometric, wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationAuthStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logIn(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationAuthStatus> {
        return authorizationInteractor
            .auth(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationAuthStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func verifyAccessUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationVerifyAccessStatus> {
        return authorizationInteractor
            .verifyAccess(type: .biometric, wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationVerifyAccessStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func verifyAccess(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationVerifyAccessStatus> {
        return authorizationInteractor
            .verifyAccess(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationVerifyAccessStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func disabledBiometricUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationAuthStatus> {
        return authorizationInteractor
            .unregisterBiometricUsingBiometric(wallet: wallet)
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationAuthStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func setEnableBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String, isOn: Bool) -> Observable<AuthorizationAuthStatus> {

        var biometric: Observable<AuthorizationAuthStatus>!

        if isOn {
            biometric = authorizationInteractor.registerBiometric(wallet: wallet, passcode: passcode)
        } else {
            biometric = authorizationInteractor.unregisterBiometric(wallet: wallet, passcode: passcode)
        }

        return biometric
            .catchError(weak: self, handler: { (owner, error) -> Observable<AuthorizationAuthStatus> in
                return Observable.error(owner.handlerError(error))
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }

    func logout(wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return authorizationInteractor.logout(wallet: wallet.publicKey)
            .map { _ in return true }
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
