//
//  AuthenticationRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum AuthenticationRepositoryError: Error {
    case fail
    case passcodeIncorrect
    case permissionDenied
    case attemptsEnded
}

protocol AuthenticationRepositoryProtocol {
    func registration(with id: String, keyForPassword: String, passcode: String) -> Observable<Bool>
    func auth(with id: String, passcode: String) -> Observable<String>
    func changePasscode(with id: String, oldPasscode: String, passcode: String) -> Observable<Bool>
}
