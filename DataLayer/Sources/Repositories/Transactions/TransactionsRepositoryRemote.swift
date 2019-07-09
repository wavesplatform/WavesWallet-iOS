//
//  TransactionsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CryptoSwift
import WavesSDKExtensions
import WavesSDK
import DomainLayer

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

extension TransactionSenderSpecifications {

    var version: Int {
        switch self {
        case .createAlias:
            return 2

        case .lease:
            return 2
            
        case .burn:
            return 2

        case .cancelLease:
            return 2

        case .data:
            return 1

        case .send:
            return 2
        }
    }

    var type: TransactionType {
        switch self {
        case .createAlias:
            return TransactionType.createAlias

        case .lease:
            return TransactionType.createLease
            
        case .burn:
            return TransactionType.burn

        case .cancelLease:
            return TransactionType.cancelLease

        case .data:
            return TransactionType.data

        case .send:
            return TransactionType.transfer
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {
    
    private let transactionRules: MoyaProvider<GitHub.Service.TransactionRules> = .anyMoyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by address: DomainLayer.DTO.Address,
                      offset: Int,
                      limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ [weak self] (servicesEnvironment) -> Observable<[DomainLayer.DTO.AnyTransaction]> in

                guard let self = self else { return Observable.never() }
                
                let limit = min(Constants.maxLimit, offset + limit)
                
                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .transactionNodeService
                    .transactions(by: address.address,
                          offset: 0,
                          limit: limit)
                    .map { $0.anyTransactions(status: .completed, environment: servicesEnvironment.walletEnvironment) }
            })
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ [weak self] (servicesEnvironment) -> Observable<[DomainLayer.DTO.LeaseTransaction]> in
                
                guard let self = self else { return Observable.never() }
                
                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .leasingNodeService
                    .leasingActiveTransactions(by: accountAddress)
                    .map { $0.map { tx in
                        return DomainLayer.DTO.LeaseTransaction(transaction: tx,
                                                                status: .activeNow,
                                                                environment: servicesEnvironment.walletEnvironment)
                        }
                    }
                    .asObservable()
            })
    }

    func send(by specifications: TransactionSenderSpecifications,
              wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction> {

        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<DomainLayer.DTO.AnyTransaction> in
                
                let walletEnvironment = servicesEnvironment.walletEnvironment
                
                let specs = specifications.broadcastSpecification(servicesEnvironment: servicesEnvironment,
                                                                                   wallet: wallet,
                                                                                   specifications: specifications)
                
                guard let broadcastSpecification = specs else { return Observable.empty() }
                
                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .transactionNodeService
                    .transactions(query: broadcastSpecification)
                    .map({ $0.anyTransaction(status: .unconfirmed, environment: walletEnvironment) })
                    .asObservable()
            })
    }

// MARK - -  Dont support
    func newTransactions(by address: DomainLayer.DTO.Address,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func transactions(by address: DomainLayer.DTO.Address,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules> {
        return transactionRules
            .rx
            .request(.get(hasProxy: true))
            .catchError({ [weak self] (_) -> PrimitiveSequence<SingleTrait, Response> in
                guard let self = self else { return Single.never() }
                return self
                    .transactionRules
                    .rx
                    .request(.get(hasProxy: false))
            })
            .map(GitHub.DTO.TransactionFeeRules.self)
            .asObservable()
            .map({ (txRules) -> DomainLayer.DTO.TransactionFeeRules in

                let deffault = txRules.calculate_fee_rules[TransactionFeeDefaultRule]

                let rules = TransactionType
                    .all
                    .reduce(into: [TransactionType: DomainLayer.DTO.TransactionFeeRules.Rule](), { (result, type) in

                    let rule = txRules.calculate_fee_rules["\(type.rawValue)"]

                    let addSmartAssetFee = (rule?.add_smart_asset_fee ?? deffault?.add_smart_asset_fee) ?? false
                    let addSmartAccountFee = (rule?.add_smart_account_fee ?? deffault?.add_smart_account_fee) ?? false
                    let minPriceStep = (rule?.min_price_step ?? deffault?.min_price_step) ?? 0
                    let fee = (rule?.fee ?? deffault?.fee) ?? 0
                    let pricePerTransfer = (rule?.price_per_transfer ?? deffault?.price_per_transfer) ?? 0
                    let pricePerKb = (rule?.price_per_kb ?? deffault?.price_per_kb) ?? 0

                    let newRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: addSmartAssetFee,
                                                                           addSmartAccountFee: addSmartAccountFee,
                                                                           minPriceStep: minPriceStep,
                                                                           fee: fee,
                                                                           pricePerTransfer: pricePerTransfer,
                                                                           pricePerKb: pricePerKb)

                    result[type] = newRule
                })


                let newDefaultRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: deffault?.add_smart_asset_fee ?? false,
                                                                              addSmartAccountFee: deffault?.add_smart_account_fee ?? false,
                                                                              minPriceStep: deffault?.min_price_step ?? 0,
                                                                              fee: deffault?.fee ?? 0,
                                                                              pricePerTransfer: deffault?.price_per_transfer ?? 0,
                                                                              pricePerKb: deffault?.price_per_kb ?? 0)


                let newRules = DomainLayer.DTO.TransactionFeeRules(smartAssetExtraFee: txRules.smart_asset_extra_fee,
                                                                   smartAccountExtraFee: txRules.smart_account_extra_fee,
                                                                   defaultRule: newDefaultRule,
                                                                   rules: rules)

                return newRules
            })
    }
}
