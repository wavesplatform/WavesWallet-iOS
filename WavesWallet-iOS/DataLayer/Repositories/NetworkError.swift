//
//  NetworkError.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case message(String)
    case notFound
}

extension NetworkError {

    static func error(by error: Error) -> NetworkError {


        return NetworkError.notFound
    }

    static func error(data: Data) -> NetworkError {


        return NetworkError.notFound
    }
}
