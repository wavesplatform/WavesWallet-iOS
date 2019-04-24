//
//  InvokeScriptTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    
    struct InvokeScriptTransaction {
        
        struct Payment {
            let amount: Int64
            let assetId: String?
        }
        
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let feeAssetId: String?
        let timestamp: Date
        let proofs: [String]?
        let version: Int
        let dappAddress: String
        let payment: Payment?
        let height: Int64
        
        var modified: Date
        var status: TransactionStatus
    }
}
