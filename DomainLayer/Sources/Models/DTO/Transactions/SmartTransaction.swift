//
//  TransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation

public struct AssetPair: Equatable {
    public var amountAsset: Asset
    public var priceAsset: Asset

    public init(amountAsset: Asset, priceAsset: Asset) {
        self.amountAsset = amountAsset
        self.priceAsset = priceAsset
    }
}

public struct SmartTransaction: Equatable {
    public typealias Account = Address

    public enum Status: Equatable {
        case activeNow
        case completed
        case unconfirmed
        case fail
    }

    public struct Transfer: Equatable {
        public let balance: DomainLayer.DTO.Balance
        public let asset: Asset

        // It is for sent too (sender)
        public let recipient: Account
        public let attachment: String?
        public let hasSponsorship: Bool

        public let myAccount: Account

        public init(
            balance: DomainLayer.DTO.Balance,
            asset: Asset,
            recipient: Account,
            attachment: String?,
            hasSponsorship: Bool,
            myAccount: Account) {
            self.balance = balance
            self.asset = asset
            self.recipient = recipient
            self.attachment = attachment
            self.hasSponsorship = hasSponsorship
            self.myAccount = myAccount
        }
    }

    public struct Exchange: Equatable {
        public struct Order: Equatable {
            public enum Kind: Equatable {
                case buy
                case sell
            }

            public let timestamp: Date
            public let expiration: Date
            public let sender: Account
            public let kind: Kind
            public let pair: AssetPair
            public let price: DomainLayer.DTO.Balance
            public let amount: DomainLayer.DTO.Balance
            public let total: DomainLayer.DTO.Balance

            public init(
                timestamp: Date,
                expiration: Date,
                sender: Account,
                kind: Kind,
                pair: AssetPair,
                price: DomainLayer.DTO.Balance,
                amount: DomainLayer.DTO.Balance,
                total: DomainLayer.DTO.Balance) {
                self.timestamp = timestamp
                self.expiration = expiration
                self.sender = sender
                self.kind = kind
                self.pair = pair
                self.price = price
                self.amount = amount
                self.total = total
            }
        }

        public let price: DomainLayer.DTO.Balance
        public let amount: DomainLayer.DTO.Balance
        public let total: DomainLayer.DTO.Balance
        public let buyMatcherFee: DomainLayer.DTO.Balance
        public let sellMatcherFee: DomainLayer.DTO.Balance
        public let order1: Order
        public let order2: Order

        public init(
            price: DomainLayer.DTO.Balance,
            amount: DomainLayer.DTO.Balance,
            total: DomainLayer.DTO.Balance,
            buyMatcherFee: DomainLayer.DTO.Balance,
            sellMatcherFee: DomainLayer.DTO.Balance,
            order1: Order,
            order2: Order) {
            self.price = price
            self.amount = amount
            self.total = total
            self.buyMatcherFee = buyMatcherFee
            self.sellMatcherFee = sellMatcherFee
            self.order1 = order1
            self.order2 = order2
        }
    }

    public struct Leasing: Equatable {
        public let asset: Asset
        public let balance: DomainLayer.DTO.Balance
        public let account: Account
        public let myAccount: Account

        public init(asset: Asset, balance: DomainLayer.DTO.Balance, account: Account, myAccount: Account) {
            self.asset = asset
            self.balance = balance
            self.account = account
            self.myAccount = myAccount
        }
    }
    
    public struct UpdateAssetInfo: Equatable {
        public let asset: Asset
        public let description: String?

        public init(asset: Asset, description: String?) {
            self.asset = asset
            self.description = description
        }
    }

    public struct Issue: Equatable {
        public let asset: Asset
        public let balance: DomainLayer.DTO.Balance
        public let description: String?

        public init(asset: Asset, balance: DomainLayer.DTO.Balance, description: String?) {
            self.asset = asset
            self.balance = balance
            self.description = description
        }
    }

    public struct MassTransfer: Equatable {
        public struct Transfer: Equatable {
            public let amount: Money
            public let recipient: Account

            public init(amount: Money, recipient: Account) {
                self.amount = amount
                self.recipient = recipient
            }
        }

        public let total: DomainLayer.DTO.Balance
        public let asset: Asset
        public let attachment: String?
        public let transfers: [Transfer]

        public init(total: DomainLayer.DTO.Balance, asset: Asset, attachment: String?, transfers: [Transfer]) {
            self.total = total
            self.asset = asset
            self.attachment = attachment
            self.transfers = transfers
        }
    }

    public struct MassReceive: Equatable {
        public struct Transfer: Equatable {
            public let amount: Money
            public let recipient: Account

            public init(amount: Money, recipient: Account) {
                self.amount = amount
                self.recipient = recipient
            }
        }

        public let total: DomainLayer.DTO.Balance
        public let myTotal: DomainLayer.DTO.Balance
        public let asset: Asset
        public let attachment: String?
        public let transfers: [Transfer]

        public init(
            total: DomainLayer.DTO.Balance,
            myTotal: DomainLayer.DTO.Balance,
            asset: Asset,
            attachment: String?,
            transfers: [Transfer]) {
            self.total = total
            self.myTotal = myTotal
            self.asset = asset
            self.attachment = attachment
            self.transfers = transfers
        }
    }

    public struct Data: Equatable {
        public let prettyJSON: String

        public init(prettyJSON: String) {
            self.prettyJSON = prettyJSON
        }
    }

    public struct InvokeScript: Equatable {
        public struct Payment: Equatable {
            public let amount: Money
            public let asset: Asset

            public init(amount: Money, asset: Asset) {
                self.amount = amount
                self.asset = asset
            }
        }

        public let payments: [Payment]?
        public let scriptAddress: String

        public init(payments: [Payment]?, scriptAddress: String) {
            self.payments = payments
            self.scriptAddress = scriptAddress
        }
    }

    public enum Kind: Equatable {
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
        case invokeScript(InvokeScript)
        
        case updateAssetInfo(UpdateAssetInfo)
    }

    public let id: String
    public let type: Int
    public let kind: Kind
    public let timestamp: Date
    public let totalFee: DomainLayer.DTO.Balance
    public let feeAsset: Asset
    public let height: Int64?
    public let confirmationHeight: Int64
    public let sender: Account
    public let status: Status

    public init(
        id: String,
        type: Int,
        kind: Kind,
        timestamp: Date,
        totalFee: DomainLayer.DTO.Balance,
        feeAsset: Asset,
        height: Int64?,
        confirmationHeight: Int64,
        sender: Account,
        status: Status) {
        self.id = id
        self.type = type
        self.kind = kind
        self.timestamp = timestamp
        self.totalFee = totalFee
        self.feeAsset = feeAsset
        self.height = height
        self.confirmationHeight = confirmationHeight
        self.sender = sender
        self.status = status
    }
}
