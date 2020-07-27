//
//  DataTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 30/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDK
import WavesSDKExtensions

extension DataTransactionRealm {
    convenience init(transaction: DataTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height ?? -1
        modified = transaction.modified

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }

        let dataList = transaction.data.map { data -> DataTransactionDataRealm in
            let txData = DataTransactionDataRealm()

            if let value = data.value {
                switch value {
                case let .bool(value):
                    txData.boolean.value = value
                case let .integer(value):
                    // TODO: Change bd
                    txData.integer.value = (value as? Int) ?? 0
                case let .string(value):
                    txData.string = value
                case let .binary(value):
                    txData.binary = value
                }
            }
            txData.key = data.key
            txData.type = data.type
            return txData
        }
        data.append(objectsIn: dataList)

        status = transaction.status.rawValue
    }
}

extension DataTransaction {
    init(transaction: NodeService.DTO.DataTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        let dataList = transaction.data.map { data -> DataTransaction.Data in

            guard let value = data.value else { return DataTransaction.Data(key: data.key,
                                                                            value: nil,
                                                                            type: data.type) }

            var dataValue: DataTransaction.Data.Value!
            switch value {
            case let .bool(value):
                dataValue = .bool(value)
            case let .integer(value):
                dataValue = .integer(value)
            case let .string(value):
                dataValue = .string(value)
            case let .binary(value):
                dataValue = .binary(value)
            }
            return DataTransaction.Data(key: data.key,
                                        value: dataValue,
                                        type: data.type)
        }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  version: transaction.version,
                  proofs: transaction.proofs,
                  data: dataList,
                  modified: Date(),
                  status: status,
                  chainId: transaction.chainId)
    }

    init(transaction: DataTransactionRealm) {
        let dataList = transaction.data.toArray().map { data -> DataTransaction.Data in

            var dataValue: DataTransaction.Data.Value!

            if let value = data.binary {
                dataValue = .binary(value)
            } else if let value = data.integer.value {
                dataValue = .integer(Int64(value))
            } else if let value = data.string {
                dataValue = .string(value)
            } else if let value = data.boolean.value {
                dataValue = .bool(value)
            }

            return DataTransaction.Data(key: data.key, value: dataValue, type: data.type)
        }

        // TODO: Chain id
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  version: transaction.version,
                  proofs: transaction.proofs.toArray(),
                  data: dataList,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed,
                  chainId: 0)
    }
}
