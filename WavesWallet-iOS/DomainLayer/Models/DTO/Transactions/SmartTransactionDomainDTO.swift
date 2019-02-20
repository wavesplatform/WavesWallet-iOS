//
//  TransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private typealias CoinomatService = Coinomat

extension DomainLayer.DTO {

    struct AssetPair: Equatable {
        var amountAsset: Asset
        var priceAsset: Asset
    }

    struct SmartTransaction: Equatable {

        typealias Asset = DomainLayer.DTO.Asset
        typealias Account = DomainLayer.DTO.Address

        enum Status: Equatable {
            case activeNow
            case completed
            case unconfirmed
        }

        struct Transfer: Equatable {
            let balance: Balance
            let asset: Asset
            let recipient: Account
            let attachment: String?
            let hasSponsorship: Bool
            var isGatewayAddress: Bool {
                return CoinomatService.addresses.contains(recipient.address)
            }
        }

        struct Exchange: Equatable {

            struct Order: Equatable {
                enum Kind: Equatable {
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

        struct Leasing: Equatable {
            let asset: Asset
            let balance: Balance
            let account: Account
        }

        struct Issue: Equatable {
            let asset: Asset
            let balance: Balance
            let description: String?            
        }

        struct MassTransfer: Equatable {
            struct Transfer: Equatable {
                let amount: Money
                let recipient: Account
            }
            let total: Balance
            let asset: Asset
            let attachment: String?
            let transfers: [Transfer]
        }

        struct MassReceive: Equatable {
            struct Transfer: Equatable {
                let amount: Money
                let recipient: Account
            }
            let total: Balance
            let myTotal: Balance
            let asset: Asset
            let attachment: String?
            let transfers: [Transfer]
        }

        struct Data: Equatable {
            let prettyJSON: String
        }

        enum Kind: Equatable {
            case receive(Transfer)
            case sent(Transfer)
            case spamReceive(Transfer)
            case selfTransfer(Transfer)
            case massSent(MassTransfer)
            case massReceived(MassReceive)
            case spamMassReceived(MassReceive)

            case startedLeasing(Leasing)
            case canceledLeasing(Leasing)
            case incomingLeasing(Leasing)

            case exchange(Exchange)

            case tokenGeneration(Issue)
            case tokenBurn(Issue)
            case tokenReissue(Issue)

            case createdAlias(String)

            case unrecognisedTransaction

            case data(Data)

            case script(isHasScript: Bool)
            case assetScript(Asset)
            case sponsorship(isEnabled: Bool, asset: Asset)

        }

        let id: String
        let kind: Kind
        let timestamp: Date
        let totalFee: Balance
        let height: Int64?
        let confirmationHeight: Int64
        let sender: Account
        let status: Status
    }
}


