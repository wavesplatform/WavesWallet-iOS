//
//  TransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
extension DomainLayer.DTO {

    struct AssetPair {
        var amountAsset: Asset
        var priceAsset: Asset
    }

    struct SmartTransaction {

        typealias Asset = DomainLayer.DTO.Asset
        typealias Account = DomainLayer.DTO.Account

        struct Transfer {
            let balance: Balance
            let asset: Asset
            let recipient: Account
            let attachment: String?
        }

        struct Exchange {

            struct Order {
                enum Kind {
                    case buy
                    case sell
                }

                let timestamp: Date
                let expiration: Date
                let sender: Account
                let kind: Kind
                let pair: AssetPair
                let price: Balance
                let amount: Balance
                let total: Balance
            }

            let price: Balance
            let amount: Balance
            let total: Balance
            let buyMatcherFee: Balance
            let sellMatcherFee: Balance
            let order1: Order
            let order2: Order
        }

        struct Leasing {
            let asset: Asset
            let balance: Balance
            let account: Account
        }

        struct Issue {
            let asset: Asset
            let balance: Balance
            let description: String?
        }

        struct MassTransfer {
            struct Transfer {
                let amount: Money
                let recipient: Account
            }

            let total: Balance
            let asset: Asset
            let attachment: String?
            let transfers: [Transfer]
        }

        struct Data {
            let prettyJSON: String
        }

        enum Kind {
            case receive(Transfer)
            case sent(Transfer)
            case spamReceive(Transfer)
            case selfTransfer(Transfer)

            case startedLeasing(Leasing)
            case canceledLeasing(Leasing)
            case incomingLeasing(Leasing)

            case exchange(Exchange)

            case tokenGeneration(Issue)
            case tokenBurn(Issue)
            case tokenReissue(Issue)

            case createdAlias(String)

            case unrecognisedTransaction

            case massSent(MassTransfer)
            case massReceived(MassTransfer)
            case spamMassReceived(MassTransfer)

            case data(Data)
        }

        let id: String
        let kind: Kind
        let timestamp: Date
        let totalFee: Balance
        let height: Int64
        let confirmationHeight: Int64
        let sender: Account
    }
}
