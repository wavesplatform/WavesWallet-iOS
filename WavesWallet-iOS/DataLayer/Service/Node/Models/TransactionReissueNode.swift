//
//  TransactionReissueNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct TransactionReissueNode {
    let type: Int
    let id: String
    let sender: String
    let senderPublicKey: String
    let fee: Int64
    let timestamp: Int64
    let signature: String
    let version: Int
    let chainID: String?
    let assetID: String
    let quantity: Int64
    let reissuable: Bool
    let height: Int64
}
