//
//  ReponceTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
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
