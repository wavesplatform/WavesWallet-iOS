//
//  NewAccountPasscodeInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DeviceKit
import DomainLayer
import Foundation
import Intercom
import RxSwift
import WavesSDKExtensions

protocol PasscodeInteractorProtocol {
    func changePassword(wallet: Wallet, passcode: String, oldPassword: String, newPassword: String) -> Observable<Wallet>
    func changePasscodeByPassword(wallet: Wallet, passcode: String, password: String) -> Observable<Wallet>
    func changePasscode(wallet: Wallet, oldPasscode: String, passcode: String) -> Observable<Wallet>

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<AuthorizationAuthStatus>

    func logIn(wallet: Wallet, passcode: String) -> Observable<AuthorizationAuthStatus>
    func logInBiometric(wallet: Wallet) -> Observable<AuthorizationAuthStatus>
    func logout(wallet: Wallet) -> Observable<Bool>

    func setEnableBiometric(wallet: Wallet, passcode: String, isOn: Bool) -> Observable<AuthorizationAuthStatus>
    func disabledBiometricUsingBiometric(wallet: Wallet) -> Observable<AuthorizationAuthStatus>

    func verifyAccessUsingBiometric(wallet: Wallet) -> Observable<AuthorizationVerifyAccessStatus>
    func verifyAccess(wallet: Wallet, passcode: String) -> Observable<AuthorizationVerifyAccessStatus>
}

final class PasscodeInteractor: PasscodeInteractorProtocol {
    private let authorizationInteractor: AuthorizationUseCaseProtocol

    init(authorizationInteractor: AuthorizationUseCaseProtocol) {
        self.authorizationInteractor = authorizationInteractor
    }

    func changePassword(wallet: Wallet, passcode: String, oldPassword: String, newPassword: String) -> Observable<Wallet> {
        authorizationInteractor
            .changePassword(wallet: wallet, passcode: passcode, oldPassword: oldPassword, newPassword: newPassword)
            .catchError(weak: self, handler: { (_, error) -> Observable<Wallet> in Observable.error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func changePasscode(wallet: Wallet, oldPasscode: String, passcode: String) -> Observable<Wallet> {
        authorizationInteractor
            .changePasscode(wallet: wallet, oldPasscode: oldPasscode, passcode: passcode)
            .catchError(weak: self, handler: { (_, error) -> Observable<Wallet> in Observable.error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func changePasscodeByPassword(wallet: Wallet, passcode: String, password: String) -> Observable<Wallet> {
        authorizationInteractor
            .changePasscodeByPassword(wallet: wallet, passcode: passcode, password: password)
            .catchError(weak: self, handler: { (_, error) -> Observable<Wallet> in Observable.error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<AuthorizationAuthStatus> {
        let query = WalletRegistation(name: account.name,
                                      address: account.privateKey.address,
                                      privateKey: account.privateKey,
                                      isBackedUp: !account.needBackup,
                                      password: account.password,
                                      passcode: passcode)

        return authorizationInteractor
            .registerWallet(query)
            .flatMap { [weak self] wallet -> Observable<AuthorizationAuthStatus> in
                guard let self = self else { return Observable.empty() }
                return self.auth(type: .passcode(passcode),
                                 wallet: wallet)
            }
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationAuthStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func logInBiometric(wallet: Wallet) -> Observable<AuthorizationAuthStatus> {
        auth(type: .biometric, wallet: wallet)
            .catchError(weak: self, handler: { _, error -> Observable<AuthorizationAuthStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func logIn(wallet: Wallet, passcode: String) -> Observable<AuthorizationAuthStatus> {
        auth(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationAuthStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func verifyAccessUsingBiometric(wallet: Wallet) -> Observable<AuthorizationVerifyAccessStatus> {
        authorizationInteractor
            .verifyAccess(type: .biometric, wallet: wallet)
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationVerifyAccessStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func verifyAccess(wallet: Wallet, passcode: String) -> Observable<AuthorizationVerifyAccessStatus> {
        authorizationInteractor
            .verifyAccess(type: .passcode(passcode), wallet: wallet)
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationVerifyAccessStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func disabledBiometricUsingBiometric(wallet: Wallet) -> Observable<AuthorizationAuthStatus> {
        authorizationInteractor
            .unregisterBiometricUsingBiometric(wallet: wallet)
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationAuthStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func setEnableBiometric(wallet: Wallet, passcode: String, isOn: Bool) -> Observable<AuthorizationAuthStatus> {
        let biometric: Observable<AuthorizationAuthStatus>!
        if isOn {
            biometric = authorizationInteractor.registerBiometric(wallet: wallet, passcode: passcode)
        } else {
            biometric = authorizationInteractor.unregisterBiometric(wallet: wallet, passcode: passcode)
        }

        return biometric
            .catchError(weak: self, handler: { (_, error) -> Observable<AuthorizationAuthStatus> in .error(error) })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func logout(wallet: Wallet) -> Observable<Bool> {
        authorizationInteractor.logout(wallet: wallet.publicKey)
            .map { _ in true }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    private func auth(type: AuthorizationType, wallet: Wallet) -> Observable<AuthorizationAuthStatus> {
        authorizationInteractor.auth(type: type, wallet: wallet)
    }
}
