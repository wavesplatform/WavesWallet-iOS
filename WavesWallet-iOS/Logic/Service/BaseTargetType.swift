//
//  APIType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {
    var apiVersion: String { get }
    var apiUrl: String { get }
}

extension BaseTargetType {
    var baseURL: URL { return URL(string: "\(apiUrl)\(apiVersion)")! }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

protocol DecodableTargetType: Moya.TargetType {
    var modelType: Encodable.Type { get }
}


extension MoyaProvider {

//    @discardableResult
//    open func request(_ target: Target,
//                      callbackQueue: DispatchQueue? = .none,
//                      progress: ProgressBlock? = .none,
//                      completion: @escaping Completion) -> Cancellable {
//
////        let callbackQueue = callbackQueue ?? self.callbackQueue
////        return requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
//    }

}

//request<T: ModelProtocol>(_ token: TargetType, object: T.Type) -> Obeservable<T>
//request<T: ModelProtocol>(_ token: TargetType, array: T.Type) -> Obeservable<[T]>
