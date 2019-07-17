//
//  TransactionsUseCaseProtocol.swift
//  InternalDomainLayer
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

public enum TransactionsUseCaseError: Error {
    case invalid
    case commissionReceiving
}

public extension DomainLayer.Query {
    enum TransactionSpecificationType {
        case createAlias
        case lease
        case burn(assetID: String)
        case cancelLease
        case sendTransaction(assetID: String)
        case createOrder(amountAsset: String, priceAsset: String, settingsOrderFee: DomainLayer.DTO.Dex.SmartSettingsOrderFee, feeAssetId: String)
    }
}

public let TransactionFeeDefaultRule: String = "default"

public protocol TransactionsUseCaseProtocol {
    
    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartTransaction>
    func transactionsSync(by accountAddress: String, specifications: TransactionsSpecifications) -> SyncObservable<[DomainLayer.DTO.SmartTransaction]>
    func activeLeasingTransactionsSync(by accountAddress: String) -> SyncObservable<[DomainLayer.DTO.SmartTransaction]>
    func calculateFee(by transactionSpecs: DomainLayer.Query.TransactionSpecificationType, accountAddress: String) -> Observable<Money>
}
