//
//  AuthenticationRepositoryRemoter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation
import RxSwift

fileprivate enum Constants {
    static let rootPath: String = "pincodes-ios-dev"
}

final class AuthenticationRepositoryRemote: AuthenticationRepositoryProtocol {

    func registration(with id: String, keyForPassword: String, passcode: String) -> Observable<Bool> {

        if passcode.count == 0 {
            return Observable.error(AuthenticationRepositoryError.fail)
        }

        return Observable.create { (observer) -> Disposable in

            let database: DatabaseReference = Database.database().reference()

            let disposable = database.child("pincodes-ios-dev/\(id)/")
                .rx
                .removeValue()
                .map { $0.child(passcode) }
                .flatMap({ ref -> Observable<DatabaseReference> in
                    ref.rx.setValue(keyForPassword)
                })
                .catchError({ _ -> Observable<DatabaseReference> in
                    Observable.error(AuthenticationRepositoryError.fail)
                })
                .subscribe(onNext: { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })

            return Disposables.create([disposable])
        }
    }

    func auth(with id: String, passcode: String) -> Observable<String> {

        return Observable.create { observer -> Disposable in

            let database: DatabaseReference = Database.database()
                .reference()
                .child("pincodes-ios-dev")
                .child(id)

            let value = self.lastTry(database: database)
                .flatMap({ nTry -> Observable<String> in

                    let changeLastTry = self.changeLastTry(database: database, nTry: nTry + 1)
                    let inputTry = self.inputPasscode(database: database,
                                                      passcode: passcode,
                                                      nTry: nTry + 1)

                    return Observable.zip([changeLastTry, inputTry])
                        .flatMap { _ -> Observable<String> in
                            self.keyForPassword(database: database, passcode: passcode)
                                .flatMap { keyForPassword -> Observable<String> in
                                    self.registration(with: id, keyForPassword: keyForPassword, passcode: passcode).map { _ in keyForPassword }
                                }
                        }
                })
                .bind(to: observer)

            return Disposables.create([value])
        }
    }

    func changePasscode(with id: String, oldPasscode: String, passcode: String) -> Observable<Bool> {
        return auth(with: id, passcode: oldPasscode)
            .flatMap { [weak self] keyForPassword -> Observable<Bool> in
                guard let owner = self else { return Observable.empty() }
                return owner.registration(with: id, keyForPassword: keyForPassword, passcode: passcode)
            }
    }

    private func lastTry(database: DatabaseReference) -> Observable<Int> {
        return database
            .child("lastTry")
            .rx
            .value
            .map({ value -> Int in
                if let value = value as? Int {
                    return value
                } else {
                    return 0
                }
            })
            .catchError({ _ -> Observable<Int> in
                Observable.error(AuthenticationRepositoryError.fail)
            })            
    }

    private func inputPasscode(database: DatabaseReference, passcode: String, nTry: Int) -> Observable<DatabaseReference> {
        return database
            .child("try/try\(nTry)")
            .rx
            .setValue(passcode)
            .catchError { error -> Observable<DatabaseReference> in
                if let error = error as NSError?, error.permissionDenied {
                    return Observable.error(AuthenticationRepositoryError.passcodeIncorrect)
                }
                return Observable.error(AuthenticationRepositoryError.fail)
            }
    }

    private func changeLastTry(database: DatabaseReference, nTry: Int) -> Observable<DatabaseReference> {
        return database
            .child("lastTry")
            .rx
            .setValue(nTry)
            .catchError { error -> Observable<DatabaseReference> in
                if let error = error as NSError?, error.permissionDenied {
                    return Observable.error(AuthenticationRepositoryError.attemptsEnded)
                }
                return Observable.error(AuthenticationRepositoryError.fail)
            }
    }

    private func keyForPassword(database: DatabaseReference, passcode: String) -> Observable<String> {
        return database
            .child(passcode)
            .rx
            .value
            .flatMap { value -> Observable<String> in
                if let value = value as? String {
                    return Observable.just(value)
                } else {
                    return Observable.error(AuthenticationRepositoryError.passcodeIncorrect)
                }
            }
    }
}

private extension NSError {
    var authError: AuthErrorCode? {
        return AuthErrorCode(rawValue: code)
    }

    var firebaseError: NSError? {
        if domain == "com.firebase" {
            return NSError(domain: domain, code: code, userInfo: userInfo)
        }
        return nil
    }

    var permissionDenied: Bool {
        return firebaseError?.code == 1
    }
}
