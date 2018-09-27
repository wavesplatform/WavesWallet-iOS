//
//  DexTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Responce <T> {
    let output: T?
    let error: Error?
    
    enum Result {
        case success(T)
        case error(Error)
    }
    
    var result: Result {
        if let output = self.output {
            return Result.success(output)
        }
        else if let error = self.error {
            return Result.error(error)
        }
        return Result.error(NSError())
    }
}

enum Dex {
    enum DTO {}
}

extension Dex.DTO {
    
    struct Asset {
        let id: String
        let name: String
        let decimals: Int
    }

    enum OrderType {
        case sell
        case buy
    }
}

