//
//  TransactionLeaseCancelNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct TransactionLeaseCancelNode {
    let type: Int
    let id: String
    let sender: String
    let senderPublicKey: String
    let fee: Int64
    let timestamp: Int64
    let signature: String
    let chainID: NSNull
    let version: Int
    let leaseID: String
    let lease: Lease
    let height: Int64
}

struct Lease {
    let type: Int
    let id: String
    let sender: String
    let senderPublicKey: String
    let fee: Int64
    let timestamp: Int64
    let signature: String
    let version: Int
    let amount: Int64
    let recipient: String
}
