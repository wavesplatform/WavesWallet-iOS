//
//  TransactionIssueNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public struct UpdateAssetInfoTransaction {
    public let type: Int
    public let id: String
    public let sender: String
    public let senderPublicKey: String
    public let fee: Int64
    public let feeAssetId: String?
    public let timestamp: Date
    public let version: Int
    public let height: Int64

    public let chainId: UInt8?
    public let proofs: [String]?
    public let assetId: String
    public let name: String
    public let description: String
    public var modified: Date
    public var status: TransactionStatus

    public init(
        type: Int,
        id: String,
        sender: String,
        senderPublicKey: String,
        fee: Int64,
        timestamp: Date,
        version: Int,
        height: Int64,
        chainId: UInt8?,
        feeAssetId: String?,
        proofs: [String]?,
        assetId: String,
        name: String,
        description: String,
        modified: Date,
        status: TransactionStatus) {
        self.type = type
        self.id = id
        self.sender = sender
        self.senderPublicKey = senderPublicKey
        self.fee = fee
        self.timestamp = timestamp
        self.version = version
        self.height = height
        self.chainId = chainId
        self.feeAssetId = feeAssetId
        self.proofs = proofs
        self.assetId = assetId
        self.name = name
        self.description = description
        self.modified = modified
        self.status = status
    }
}
