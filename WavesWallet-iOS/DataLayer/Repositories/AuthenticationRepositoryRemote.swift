//
//  AuthenticationRepositoryRemoter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseDatabase

final class AuthenticationRepositoryRemote: AuthenticationRepositoryProtocol {

    private let ref: DatabaseReference = Database.database().reference()

    func registration(with id: String, keyForPassword: String, passcode: String) -> Observable<Bool> {
        
        return AsyncObservable.never()
    }

    func auth(with id: String, passcode: String) -> Observable<String> {
        return AsyncObservable.never()
    }

    func changePasscode(with id: String, oldPasscode: String, passcode: String) -> Observable<Bool> {
        return AsyncObservable.never()
    }
}
