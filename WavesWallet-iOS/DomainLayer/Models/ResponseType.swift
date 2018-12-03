//
//  ReponceTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct ResponseType <T> {
    
    let output: T?
    let error: NetworkError?
    
    enum Result {
        case success(T)
        case error(NetworkError)
    }
    
    var result: Result {
        if let output = self.output {
            return Result.success(output)
        }
        else if let error = self.error {
            return Result.error(error)
        }
        return Result.error(.notFound)
    }
}

