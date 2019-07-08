//
//  UnrecognisedTransactionNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct UnrecognisedTransaction: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Date
        let height: Int64
    }
}
