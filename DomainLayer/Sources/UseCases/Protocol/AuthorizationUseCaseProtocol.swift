//
//  AuthorizationUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 09/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public enum AuthorizationType {
    case passcode(String)
    // The password by format sha512
    case password(String)
    case biometric
}

public enum AuthorizationUseCaseError: Error {
    case fail
    case walletAlreadyExist
    case walletNotFound
    case passcodeNotCreated
    case passcodeIncorrect
    case passwordIncorrect
    case permissionDenied
    case attemptsEnded
    case biometricDisable
    case biometricUserCancel
    case biometricLockout
    case biometricUserFallback
}

public enum AuthorizationAuthStatus {
    case detectBiometric
    case waiting
    case completed(Wallet)
}

public enum AuthorizationVerifyAccessStatus {
    case detectBiometric
    case waiting
    case completed(SignedWallet)
}

public protocol AuthorizationInteractorLocalizableProtocol {
    var fallbackTitle: String { get }
    var cancelTitle: String { get }
    var readFromkeychain: String { get }
    var saveInkeychain: String { get }
}

public protocol AuthorizationUseCaseProtocol {

    func existWallet(by publicKey: String) -> Observable<Wallet>
    func wallets() -> Observable<[Wallet]>
    func registerWallet(_ wallet: WalletRegistation) -> Observable<Wallet>
    func deleteWallet(_ wallet: Wallet) -> Observable<Bool>
    func changeWallet(_ wallet: Wallet) -> Observable<Wallet>

    func lastWalletLoggedIn() -> Observable<Wallet?>
    func walletsLoggedIn() -> Observable<[Wallet]>

    //passcodeNotCreated or permissionDenied
    func hasPermissionToLoggedIn(_ wallet: Wallet) -> Observable<Bool>

    // Return AuthorizationUseCaseError permissionDenied
    func authorizedWallet() -> Observable<SignedWallet>
    func isAuthorizedWallet(_ wallet: Wallet) -> Observable<Bool>

    // Return AuthorizationUseCaseError
    func auth(type: AuthorizationType, wallet: Wallet) -> Observable<AuthorizationAuthStatus>
    func verifyAccess(type: AuthorizationType, wallet: Wallet) -> Observable<AuthorizationVerifyAccessStatus>

    func registerBiometric(wallet: Wallet, passcode: String) -> Observable<AuthorizationAuthStatus>
    func unregisterBiometric(wallet: Wallet, passcode: String) -> Observable<AuthorizationAuthStatus>
    func unregisterBiometricUsingBiometric(wallet: Wallet) -> Observable<AuthorizationAuthStatus>

    func logout(wallet publicKey: String) -> Observable<Wallet>
    func logout() -> Observable<Wallet>
    func revokeAuth() -> Observable<Bool>

    func changePasscode(wallet: Wallet, oldPasscode: String, passcode: String) -> Observable<Wallet>
    func changePasscodeByPassword(wallet: Wallet, passcode: String, password: String) -> Observable<Wallet>

    func changePassword(wallet: Wallet, passcode: String, oldPassword: String, newPassword: String) -> Observable<Wallet>
}
