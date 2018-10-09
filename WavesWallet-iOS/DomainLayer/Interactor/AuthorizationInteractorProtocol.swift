//
//  AuthorizationInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 09/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

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

enum AuthorizationBiometricStatus {
    case detectBiometric
    case waiting
    case completed(DomainLayer.DTO.Wallet)
}

protocol AuthorizationInteractorProtocol {

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]>
    func registerWallet(_ wallet: DomainLayer.DTO.WalletRegistation) -> Observable<DomainLayer.DTO.Wallet>
    func deleteWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
    func changeWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    func lastWalletLoggedIn() -> Observable<DomainLayer.DTO.Wallet?>
    func walletsLoggedIn() -> Observable<[DomainLayer.DTO.Wallet]>

    // Return AuthorizationInteractorError permissionDenied
    func authorizedWallet() -> Observable<DomainLayer.DTO.SignedWallet>
    func isAuthorizedWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>

    // Return AuthorizationInteractorError
    func auth(type: AuthorizationType, wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationBiometricStatus>

    func registerBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationBiometricStatus>
    func unregisterBiometric(wallet: DomainLayer.DTO.Wallet, passcode: String) -> Observable<AuthorizationBiometricStatus>
    func unregisterBiometricUsingBiometric(wallet: DomainLayer.DTO.Wallet) -> Observable<AuthorizationBiometricStatus>

    func logout(wallet publicKey: String) -> Observable<DomainLayer.DTO.Wallet>
    func logout() -> Observable<DomainLayer.DTO.Wallet>
    func revokeAuth() -> Observable<Bool>

    func changePasscode(wallet: DomainLayer.DTO.Wallet, oldPasscode: String, passcode: String) -> Observable<DomainLayer.DTO.Wallet>
    func changePasscodeByPassword(wallet: DomainLayer.DTO.Wallet, passcode: String, password: String) -> Observable<DomainLayer.DTO.Wallet>
}
