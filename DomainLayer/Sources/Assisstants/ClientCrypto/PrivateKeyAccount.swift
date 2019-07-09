//
//  PrivateKeyAccount.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 10/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto

public class PrivateKeyAccount: PublicKeyAccount {
    
    public let privateKey: [UInt8]
    public let seed: [UInt8]
    
    public init(seed: [UInt8]) {
        self.seed = seed
        let nonce : [UInt8] = [0, 0, 0, 0]
        let hashSeed = Hash.sha256(Hash.secureHash(nonce + seed))
        let pair = Curve25519.generateKeyPair(Data(hashSeed))!
        privateKey = Array(pair.privateKey())
        super.init(publicKey: Array(pair.publicKey()))
    }

    public var privateKeyStr: String {
        return Base58Encoder.encode(privateKey)
    }

    public var words: [String] {
        return String(data: Data(seed), encoding: .utf8)?.components(separatedBy: " ") ?? []
    }
    
    public var wordsStr: String {
        return String(data: Data(seed), encoding: .utf8) ?? ""
    }
    
    public convenience init(seedStr: String) {
        self.init(seed: Array(seedStr.utf8))
    }
}

