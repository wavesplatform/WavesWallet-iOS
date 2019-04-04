//
//  String+SHA.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import CryptoSwift
import RxSwift

public enum Crypto {}
extension Crypto: ReactiveCompatible {}

public extension Reactive where Base == Crypto {

    static func sha256(_ string: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in

            observer.onNext(string.sha256())
            observer.onCompleted()

            return Disposables.create()
        })
    }

    static func sha512(_ string: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in

            observer.onNext(string.sha512())
            observer.onCompleted()

            return Disposables.create()
        })
    }
}

