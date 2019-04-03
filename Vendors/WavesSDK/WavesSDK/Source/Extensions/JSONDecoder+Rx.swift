//
//  JSONDecodable+Rx.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public extension JSONDecoder {

    static func decode<Type: Decodable>(type: Type.Type, json name: String) -> Observable<Type> {

        return Observable.create { (observer) -> Disposable in

            do {
                let decoder = JSONDecoder()

                let dateFormate = DateFormatter.sharedFormatter
                dateFormate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                decoder.dateDecodingStrategy = .formatted(dateFormate)

                let file = Bundle.main.path(forResource: name, ofType: "json")!
                let data = try Data(contentsOf: URL(fileURLWithPath: file))
                let element = try decoder.decode(type, from: data)

                observer.onNext(element)
            } catch let error {
                SweetLogger.debug(error)
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
