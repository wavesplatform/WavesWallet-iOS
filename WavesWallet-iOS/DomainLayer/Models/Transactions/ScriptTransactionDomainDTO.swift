//
//  SetScriptTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct ScriptTransaction {

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let version: Int
        let height: Int64?
        let chainId: Int?

        let signature: String?
        let proofs: [String]?        
        var script: String?
        var modified: Date
        var status: TransactionStatus
    }
}
