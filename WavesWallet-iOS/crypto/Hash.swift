//
//  Hash.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 11/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import keccak
import blake2
import _25519

class Hash {
    static func secureHash(_ input: [UInt8]) -> [UInt8] {
        var data = Data(count: 32)
        var key: UInt8 = 0
        data.withUnsafeMutableBytes {(bytes: UnsafeMutablePointer<UInt8>)->Void in
            crypto_generichash_blake2b(bytes, 32, input, UInt64(input.count), &key, 0)
        }
        var res = Data(count: 32)
        res.withUnsafeMutableBytes {(bytes: UnsafeMutablePointer<UInt8>)->Void in
            keccak(Array(data), Int32(data.count), bytes, 32)
        }
        return Array(res)
    }
    
    static func fastHash(_ input: [UInt8]) -> [UInt8] {
        var res = Data(count: 32)
        var key: UInt8 = 0
        res.withUnsafeMutableBytes {(bytes: UnsafeMutablePointer<UInt8>)->Void in
            crypto_generichash_blake2b(bytes, 32, input, UInt64(input.count), &key, 0)
        }
        return Array(res)
    }
    
    static func sign(_ input: [UInt8], _ key: [UInt8]) -> [UInt8] {
        return Array(Curve25519.sign(Data(input), withPrivateKey: Data(key)))
    }
    
    static func sha256(_ data: [UInt8]) -> [UInt8] {
        
        let len = Int(CC_SHA256_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: len)
        
        CC_SHA256(data, CC_LONG(data.count), &digest)
        
        return Array(digest[0..<len])
    }
    
}
