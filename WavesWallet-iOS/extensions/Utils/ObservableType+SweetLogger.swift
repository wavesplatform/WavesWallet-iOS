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
    debug("\(identifier) -> \(message)")
}

extension ObservableType {

    func sweetDebug(_ identifier: String) -> RxSwift.Observable<Self.E> {

        return self.do(onNext: { element in
            let name = Thread.current.name ?? ""
            log(identifier: identifier, message: "\(name) onNext \(element)")
        }, onError: { error in
           log(identifier: identifier, message: "onError")
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
