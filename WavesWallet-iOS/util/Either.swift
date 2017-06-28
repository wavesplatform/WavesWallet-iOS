//
//  Either.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 19/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

enum Either<A, B> {
    case Left(A)
    case Right(B)
}

enum Try<A> {
    case Err(String)
    case Val(A)
    
    var toOpt: A? {
        switch self {
        case .Err: return nil
        case .Val(let a): return a
        }
    }
    
    var error: String? {
        switch self {
        case .Err(let str): return str
        case .Val: return nil
        }
    }
    
    var exists: Bool {
        switch self {
        case .Err: return false
        case .Val: return true
        }
    }
}
