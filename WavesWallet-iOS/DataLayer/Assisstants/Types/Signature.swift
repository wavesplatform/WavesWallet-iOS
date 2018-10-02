//
//  Signature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

fileprivate enum Constants {
    static let senderPublicKey = "senderPublicKey"
    static let signature = "signature"
}

protocol SignatureProtocol {
    associatedtype Variable: CustomStringConvertible

    var signedWallet: DomainLayer.DTO.SignedWallet { get }

    var variable: Variable { get }
    var variableKey: String { get }

    var toSign: [UInt8] { get }
    var parameters: [String: String] { get }

    func signature() -> [UInt8]
}

extension SignatureProtocol {

    var publicKey: PublicKeyAccount {
        return signedWallet.publicKey
    }

    var toSign: [UInt8] {
        let s1 = signedWallet.publicKey.publicKey
        let s2 = toByteArray(variable)
        return s1 + s2
    }

    func signature() -> [UInt8] {
        return (try? signedWallet.sign(input: toSign, kind: [.none])) ?? []
    }

    var parameters: [String: String] {
        return [Constants.senderPublicKey: Base58.encode(signedWallet.publicKey.publicKey),
                variableKey: "\(variable)",
                Constants.signature: Base58.encode(signature())]
    }
}
