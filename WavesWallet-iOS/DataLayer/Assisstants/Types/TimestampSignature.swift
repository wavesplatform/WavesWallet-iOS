//
//  TimestampSignature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

fileprivate enum Constants {
    static let timestamp = "timestamp"
}

struct TimestampSignature: SignatureProtocol {

    typealias Variable = Int64

    private(set) var signedWallet: DomainLayer.DTO.SignedWallet
    private(set) var variable: Variable
    
    var variableKey: String {
        return Constants.timestamp
    }
}

extension TimestampSignature {
    init(signedWallet: DomainLayer.DTO.SignedWallet, environment: Environment) {
        self.init(signedWallet: signedWallet, variable: Date().millisecondsSince1970(timestampDiff: environment.timestampServerDiff))        
    }
}
