//
//  AccountPasswordInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

enum AccountPasswordInteractorError: Error {
    case fail
    case passcodeIncorrect
    case permissionDenied
}

protocol AccountPasswordInteractorProtocol {
    func logIn(wallet: DomainLayer.DTO.Wallet, password: String) -> Observable<Bool>
}

final class AccountPasswordInteractor: AccountPasswordInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    func logIn(wallet: DomainLayer.DTO.Wallet, password: String) -> Observable<Bool> {

        return authorizationInteractor
            .auth(type: .password(password), wallet: wallet)
            .map { _ in true }
            .catchError(weak: self, handler: { (owner, error) -> Observable<Bool> in
                return Observable.error(owner.handlerError(error))
            })
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    private func handlerError(_ error: Error) -> PasscodeInteractorError {

        switch error {
        case let authError as AuthorizationInteractorError:
            switch authError {
            case .attemptsEnded:
                return PasscodeInteractorError.attemptsEnded

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

