//
//  AuthenticationRepositoryRemoter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions
import DomainLayer

fileprivate enum Constants {
    #if DEBUG
    static let rootPath: String = "pincodes-ios-dev"
    #elseif TEST
    static let rootPath: String = "pincodes-ios-dev"
    #else
    static let rootPath: String = "pincodes-ios"
    #endif
    
    static let firebaseAppWavesPlatform: String = "WavesPlatform"
}

final class AuthenticationRepositoryRemote: AuthenticationRepositoryProtocol {
    
    private var wavesPlatformDatabase: Database? = {
        
        guard let app = FirebaseApp.app(name: Constants.firebaseAppWavesPlatform) else {
            return nil
        }
        
        return Database.database(app: app)
    }()
    
    func registration(with id: String, keyForPassword: String, passcode: String) -> Observable<Bool> {

        let database: Database = Database.database()
        return registration(with: id, keyForPassword: keyForPassword, passcode: passcode, database: database)
    }

    func auth(with id: String, passcode: String) -> Observable<String> {

        return Observable.create { observer -> Disposable in

            guard let wavesPlatformDatabase = self.wavesPlatformDatabase else {
                return Disposables.create()
            }
                        
            let wavesExchangeDatabase: Database = Database.database()
            
            let value = self.auth(with: id,
                                  passcode: passcode,
                                  database: wavesExchangeDatabase)
                .catchError { (error) -> Observable<String> in
                    
                    return self
                        .auth(with: id,
                              passcode: passcode,
                              database: wavesPlatformDatabase)
                        .flatMap { (keyForPassword) -> Observable<String> in
                            return self.registration(with: id,
                                                     keyForPassword: keyForPassword,
                                                     passcode: passcode,
                                                     database: wavesExchangeDatabase)
                                .map { _ in return keyForPassword }
                    }
                    .flatMap { (keyForPassword) -> Observable<String> in
                        return self.removeAccount(with: id,
                                                  database: wavesPlatformDatabase)
                            .map { _ in keyForPassword }
                    }
                    .catchError { (wavesError) -> Observable<String> in
                        return Observable.error(error)
                    }
                }
                .bind(to: observer)
            
            return Disposables.create([value])
        }
    }
    
    func changePasscode(with id: String, oldPasscode: String, passcode: String) -> Observable<Bool> {
        return auth(with: id, passcode: oldPasscode)
            .flatMap { [weak self] keyForPassword -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.registration(with: id, keyForPassword: keyForPassword, passcode: passcode)
            }
    }
    
    private func removeAccount(with id: String, database: Database) -> Observable<Bool> {

        return Observable.create { (observer) -> Disposable in

            let database: DatabaseReference = database.reference()

            let disposable = database.child("\(Constants.rootPath)/\(id)/")
                .rx
                .removeValue()
                .subscribe(onNext: { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(self.handlerError(error: error))
                })

            return Disposables.create([disposable])
        }
    }

    //TODO: Check case when remove value internet dissconect
    private func registration(with id: String,
                              keyForPassword: String,
                              passcode: String,
                              database: Database) -> Observable<Bool> {

        if passcode.count == 0 {
            return Observable.error(AuthenticationRepositoryError.fail)
        }

        return Observable.create { (observer) -> Disposable in

            let database: DatabaseReference = database.reference()

            let disposable = database.child("\(Constants.rootPath)/\(id)/")
                .rx
                .removeValue()
                .map { $0.child(passcode) }
                .flatMap({ ref -> Observable<DatabaseReference> in
                    ref.rx.setValue(keyForPassword)
                })
                .subscribe(onNext: { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(self.handlerError(error: error))
                })

            return Disposables.create([disposable])
        }
    }
    
    private func auth(with id: String,
                      passcode: String,
                      database: Database) -> Observable<String> {

           return Observable.create { observer -> Disposable in

               let database: DatabaseReference = database
                   .reference()
                   .child(Constants.rootPath)
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
                   .catchError({ (error) -> Observable<String> in
                       return Observable.error(self.handlerError(error: error))
                   })
                   .bind(to: observer)

               return Disposables.create([value])
           }
       }
    
    private func logError(error: Error) {
        
        if error is AuthenticationRepositoryError {
            SweetLogger.error("AuthorizationUseCaseError.attemptsEnded")
        } else {
            switch NetworkError.error(by: error) {
            case .none:
                SweetLogger.error("AuthenticationRepositoryRemote.none")
            case .message(let message):
                SweetLogger.error("AuthenticationRepositoryRemote.message = \(message)")
            case .notFound:
                SweetLogger.error("AuthenticationRepositoryRemote.notFound")
            case .internetNotWorking:
                SweetLogger.error("AuthenticationRepositoryRemote.internetNotWorking")
            case .serverError:
                SweetLogger.error("AuthenticationRepositoryRemote.serverError")
            case .scriptError:
                SweetLogger.error("AuthenticationRepositoryRemote.scriptError")
            }
        }
    }
        
    private func handlerError(error: Error) -> Error {
                
        if error is AuthenticationRepositoryError {
            return error
        } else {
            return NetworkError.error(by: error)
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
                return Observable.error(NetworkError.error(by: error))
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
                return Observable.error(NetworkError.error(by: error))
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
