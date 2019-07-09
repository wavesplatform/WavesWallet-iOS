//
//  Signature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDKCrypto
import DomainLayer
import Extensions

//TODO: Signature Protocol need remove and is using Signature Protocol from SDK
protocol SignatureProtocol {

    var signedWallet: DomainLayer.DTO.SignedWallet { get }
    
    var toSign: [UInt8] { get }
    
    func signature() -> [UInt8]
    
    func signature() -> String
}

extension SignatureProtocol {

    var publicKey: PublicKeyAccount {
        return signedWallet.publicKey
    }

    func signature() -> [UInt8] {
        return (try? signedWallet.sign(input: toSign, kind: [.none])) ?? []
    }
    
    func signature() -> String {
        return Base58Encoder.encode(signature())
    }
}
