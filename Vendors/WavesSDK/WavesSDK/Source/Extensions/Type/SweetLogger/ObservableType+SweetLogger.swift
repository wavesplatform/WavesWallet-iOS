//
//  ObservableType+SweetLogger.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private func log(identifier: String, message: String) {
    let name = Thread.current.displayName

    SweetLogger.debug("▶️ \(name) ◀️ \(identifier) -> \(message)")
}

private extension Thread {

    var displayName: String {
        if let name = Thread.current.name, name.count > 0 {
            return name
        } else {
            return "Global"
        }
    }
}

public extension ObservableType {

    func sweetDebugWithoutResponse(_ identifier: String) -> RxSwift.Observable<Self.E> {

        return self.do(onNext: { element in
            log(identifier: identifier, message: "onNext 💬")
        }, onError: { error in
            log(identifier: identifier, message: "onError \(error)")
        }, onCompleted: {
            log(identifier: identifier, message: "onCompleted")
        }, onSubscribe: {
            log(identifier: identifier, message: "onSubscribe")
        }, onSubscribed: {
            log(identifier: identifier, message: "onSubscribed")
        }, onDispose: {
            log(identifier: identifier, message: "onDispose")
        })
    }

    func sweetDebug(_ identifier: String) -> RxSwift.Observable<Self.E> {

        return self.do(onNext: { element in
            log(identifier: identifier, message: "onNext \(element)")
        }, onError: { error in
            log(identifier: identifier, message: "onError \(error)")
        }, onCompleted: {
            log(identifier: identifier, message: "onCompleted")
        }, onSubscribe: {
            log(identifier: identifier, message: "onSubscribe")
        }, onSubscribed: {
            log(identifier: identifier, message: "onSubscribed")
        }, onDispose: {
            log(identifier: identifier, message: "onDispose")
        })
    }
}
