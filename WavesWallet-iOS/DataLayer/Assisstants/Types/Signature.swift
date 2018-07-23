//
//  Signature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private enum Constants {
    static let senderPublicKey = "senderPublicKey"
    static let signature = "signature"
}

protocol SignatureProtocol {
    associatedtype Variable: CustomStringConvertible

    var privateKey: PrivateKeyAccount { get }
    var variable: Variable { get }
    var toSign: [UInt8] { get }
    var signature: [UInt8] { get }
    var variableKey: String { get }
    var parameters: [String: String] { get }
}

extension SignatureProtocol {
    var toSign: [UInt8] {
        let s1 = privateKey.publicKey
        let s2 = toByteArray(variable)
        return s1 + s2
    }

    var signature: [UInt8] {
        let b = toSign
        return Hash.sign(b, privateKey.privateKey)
    }

    var parameters: [String: String] {
        return [Constants.senderPublicKey: Base58.encode(privateKey.publicKey),
                variableKey: "\(variable)",
                Constants.signature: Base58.encode(signature)]
    }
}
