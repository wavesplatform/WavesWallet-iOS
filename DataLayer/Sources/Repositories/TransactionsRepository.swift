//
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import CryptoSwift
import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let maxLimit: Int = 10000
    static let feeRuleJsonName = "fee"
}

extension TransactionSenderSpecifications {
    var version: Int {
        switch self {
        case .createAlias: return 2
        case .lease: return 2
        case .burn: return 2
        case .cancelLease: return 2
        case .data: return 1
        case .send: return 2
        case .invokeScript: return 1
        }
    }
    
    var type: TransactionType {
        switch self {
        case .invokeScript: return TransactionType.invokeScript
        case .createAlias: return TransactionType.createAlias
        case .lease: return TransactionType.createLease
        case .burn: return TransactionType.burn
        case .cancelLease: return TransactionType.cancelLease
        case .data: return TransactionType.data
        case .send: return TransactionType.transfer
        }
    }
}

final class TransactionsRepository: TransactionsRepositoryProtocol {
    private let transactionRules: MoyaProvider<ResourceAPI.Service.TransactionRules> = .anyMoyaProvider()
        
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {        
        self.wavesSDKServices = wavesSDKServices
    }
    
    func transactions(serverEnvironment: ServerEnvironment,
                      address: Address,
                      offset: Int,
                      limit: Int) -> Observable<[AnyTransaction]> {
        
        let wavesServices = wavesSDKServices
            .wavesServices(environment: serverEnvironment)
        
        let limit = min(Constants.maxLimit, offset + limit)
        
        return wavesServices
            .nodeServices
            .transactionNodeService
            .transactions(by: address.address,
                          offset: 0,
                          limit: limit)
            .map { $0.anyTransactions(status: nil,                                      
                                      aliasScheme: serverEnvironment.aliasScheme) }
        
    }
    
    func activeLeasingTransactions(serverEnvironment: ServerEnvironment,
                                   accountAddress: String) -> Observable<[LeaseTransaction]> {
        
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnvironment)
        
        return wavesServices
            .nodeServices
            .leasingNodeService
            .leasingActiveTransactions(by: accountAddress)
            .map {
                $0.map { tx in
                    LeaseTransaction(transaction: tx,
                                                     status: .activeNow,
                                                     aliasScheme: serverEnvironment.aliasScheme)
                }
        }
        .asObservable()
    }
    
    func send(serverEnvironment: ServerEnvironment, specifications: TransactionSenderSpecifications, wallet: SignedWallet)
        -> Observable<AnyTransaction> {
        
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnvironment)
                                        
        let specs = specifications.broadcastSpecification(serverEnvironment: serverEnvironment,
                                                          wallet: wallet,
                                                          specifications: specifications)
        
        guard let broadcastSpecification = specs else { return Observable.empty() }
        
        return wavesServices
            .nodeServices
            .transactionNodeService
            .transactions(query: broadcastSpecification)
            .map { $0.anyTransaction(status: .unconfirmed,                                     
                                     aliasScheme: serverEnvironment.aliasScheme) }
            .asObservable()
        
    }
        
    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules> {
        transactionRules
            .rx
            .request(.get)
            .map(ResourceAPI.DTO.TransactionFeeRules.self)
            .catchError { error -> Single<ResourceAPI.DTO.TransactionFeeRules> in
                if let rule: ResourceAPI.DTO.TransactionFeeRules = JSONDecoder.decode(json: Constants.feeRuleJsonName) {
                    return Single.just(rule)
                } else {
                    return Single.error(error)
                }
        }
        .asObservable()
        .map { txRules -> DomainLayer.DTO.TransactionFeeRules in
            
            let deffault = txRules.calculate_fee_rules[TransactionFeeDefaultRule]
            
            let rules = TransactionType
                .all
                .reduce(into: [TransactionType: DomainLayer.DTO.TransactionFeeRules.Rule]()) { result, type in
                    
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
            }
            
            let addSmartAssetFee = deffault?.add_smart_asset_fee ?? false
            let addSmartAccountFee = deffault?.add_smart_account_fee ?? false
            let newDefaultRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: addSmartAssetFee,
                                                                          addSmartAccountFee: addSmartAccountFee,
                                                                          minPriceStep: deffault?.min_price_step ?? 0,
                                                                          fee: deffault?.fee ?? 0,
                                                                          pricePerTransfer: deffault?.price_per_transfer ?? 0,
                                                                          pricePerKb: deffault?.price_per_kb ?? 0)
            
            let newRules = DomainLayer.DTO.TransactionFeeRules(smartAssetExtraFee: txRules.smart_asset_extra_fee,
                                                               smartAccountExtraFee: txRules.smart_account_extra_fee,
                                                               defaultRule: newDefaultRule,
                                                               rules: rules)
            
            return newRules
        }
    }
}
