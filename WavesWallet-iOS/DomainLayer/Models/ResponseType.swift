//
//  ReponceTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct ResponseTypeError {
    let message: String
    let code: Int
}

struct ResponseType <T> {
    
    let output: T?
    let error: ResponseTypeError?
    
    enum Result {
        case success(T)
        case error(ResponseTypeError)
    }
    
    var result: Result {
        if let output = self.output {
            return Result.success(output)
        }
        else if let error = self.error {
            return Result.error(error)
        }
        return Result.error(.init(message: "Try again", code:0))
    }
}

