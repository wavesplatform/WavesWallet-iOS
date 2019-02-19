//
//  SigningWalletsProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum SigningWalletsError: Error {
    case accessDenied
    case notSigned
}

enum SigningKind {
    case none
}

protocol SigningWalletsProtocol: AnyObject {
    func sign(input: [UInt8], kind: [SigningKind], publicKey: String) throws -> [UInt8]
}
