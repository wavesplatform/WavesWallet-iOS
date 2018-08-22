//
//  TransactionDataNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct TransactionDataNode {
    let type: Int
    let id: String
    let sender: String
    let senderPublicKey: String
    let fee: Int
    let timestamp: Int
    let proofs: [String]
    let version: Int
    let data: [Datum]
    let height: Int
}

struct Datum {
    let key: String
    let type: String
    let value: Value
}

enum Value {
    case bool(Bool)
    case integer(Int)
    case string(String)
}

