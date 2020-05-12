//
//  WavesExchangeGatewayRepositoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import RxSwift

extension DomainLayer.Query {
    public enum WEGateway {}
}

extension DomainLayer.DTO {
    public enum WEGateway {}
}

extension DomainLayer.Query.WEGateway {
    
    public struct TransferBinding {
        public let senderAsset: String
        public let recipientAsset: String
        public let recipientAddress: String
        public let token: WEOAuthTokenDTO

        public init(senderAsset: String,
                    recipientAsset: String,
                    recipientAddress: String,
                    token: WEOAuthTokenDTO) {
            self.senderAsset = senderAsset
            self.recipientAsset = recipientAsset
            self.recipientAddress = recipientAddress
            self.token = token
        }
    }
        
    public struct RegisterOrder {
        public let amount: Decimal
        public let assetId: String
        public let address: String
        public let token: WEOAuthTokenDTO
        
        public init(amount: Decimal,
                    assetId: String,
                    address: String,
                    token: WEOAuthTokenDTO) {
            self.amount = amount
            self.assetId = assetId
            self.address = address
            self.token = token
        }
    }
}

//TODO: После переходна grpc надо бы его удалить
extension DomainLayer.DTO.WEGateway {
    
    public struct TransferBinding {
        public var addresses: [String]
        public var amountMin: Int64
        public var amountMax: Int64
        public var taxRate: Double
        public var taxFlat: Int64

        public init(addresses: [String],
                    amountMin: Int64,
                    amountMax: Int64,
                    taxRate: Double,
                    taxFlat: Int64) {
            
            self.addresses = addresses
            self.amountMin = amountMin
            self.amountMax = amountMax
            self.taxRate = taxRate
            self.taxFlat = taxFlat
        }
    }
    
    public struct ReceiveBinding {
        public var addresses: [String]
        public var amountMin: Money
        public var amountMax: Money

        public init(addresses: [String],
                    amountMin: Money,
                    amountMax: Money) {
            self.addresses = addresses
            self.amountMin = amountMin
            self.amountMax = amountMax            
        }
    }
    
    public struct SendBinding {
        public var addresses: [String]
        public var amountMin: Money
        public var amountMax: Money
        public var fee: Money

        public init(addresses: [String],
                    amountMin: Money,
                    amountMax: Money,
                    fee: Money) {
            self.addresses = addresses
            self.amountMin = amountMin
            self.amountMax = amountMax
            self.fee = fee
        }
    }
    
    public struct Order {
        public var url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
}

public protocol WEGatewayRepositoryProtocol {
    func transferBinding(serverEnvironment: ServerEnvironment,
                         request: DomainLayer.Query.WEGateway.TransferBinding) -> Observable<DomainLayer.DTO.WEGateway.TransferBinding>
    
    func adCashDepositsRegisterOrder(serverEnvironment: ServerEnvironment,
                                     request: DomainLayer.Query.WEGateway.RegisterOrder) -> Observable<DomainLayer.DTO.WEGateway.Order>
}
