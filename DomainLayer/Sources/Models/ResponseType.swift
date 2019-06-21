//
//  ReponceTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK

public struct ResponseType <T> {
    
    public let output: T?
    public let error: NetworkError?

    public init(output: T?, error: NetworkError?) {
        self.output = output
        self.error = error
    }
    
    public enum Result {
        case success(T)
        case error(NetworkError)
    }
    
    public var result: Result {
        if let output = self.output {
            return Result.success(output)
        }
        else if let error = self.error {
            return Result.error(error)
        }
        return Result.error(.notFound)
    }
}

