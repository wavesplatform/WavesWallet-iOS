//
//  CorrectionPairsUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import WavesSDKCrypto

public protocol CorrectionPairsUseCaseLogicProtocol {
    static func mapCorrectPairs(settingsIdsPairs: [String], pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> [DomainLayer.DTO.CorrectionPairs.Pair]
}

public final class CorrectionPairsUseCaseLogic: CorrectionPairsUseCaseLogicProtocol {
    
    public init() {}
    
    public static func mapCorrectPairs(settingsIdsPairs: [String], pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> [DomainLayer.DTO.CorrectionPairs.Pair] {
        
        let result = pairs.map({ (pair) -> DomainLayer.DTO.CorrectionPairs.Pair in
            
            let amounIndex = settingsIdsPairs.firstIndex(of: pair.amountAsset)
            let priceIndex = settingsIdsPairs.firstIndex(of: pair.priceAsset)
            
            var amount: String! = nil
            var price: String! = nil
            
            if let amounIndex = amounIndex, let priceIndex = priceIndex {
                if amounIndex > priceIndex {
                    amount = pair.amountAsset
                    price = pair.priceAsset
                } else {
                    amount = pair.priceAsset
                    price = pair.amountAsset
                }
            } else if amounIndex != nil && priceIndex == nil {
                amount = pair.priceAsset
                price = pair.amountAsset
            } else if priceIndex != nil && amounIndex == nil {
                amount = pair.amountAsset
                price = pair.priceAsset
            } else {
                                
                let amountBytes = Data(fromArray: WavesCrypto.shared.base58decode(input: pair.amountAsset) ?? [])
                let priceBytes = Data(fromArray: WavesCrypto.shared.base58decode(input: pair.priceAsset) ?? [])

                let amountHex = amountBytes.hexDescription
                let priceHex = priceBytes.hexDescription
                
                if amountHex > priceHex {
                    amount = pair.amountAsset
                    price = pair.priceAsset
                } else {
                    amount = pair.priceAsset
                    price = pair.amountAsset
                }
            }
            
            return DomainLayer.DTO.CorrectionPairs.Pair.init(amountAsset: amount,
                                                             priceAsset: price)
        })
        
        return result
    }
}

final class CorrectionPairsUseCase: CorrectionPairsUseCaseProtocol {
    
    private let repositories: RepositoriesFactoryProtocol
    private let useCases: UseCasesFactoryProtocol
    
    init(repositories: RepositoriesFactoryProtocol, useCases: UseCasesFactoryProtocol) {
        self.repositories = repositories
        self.useCases = useCases
    }
    
    func correction(pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> {
        
        return useCases
            .serverEnvironmentUseCase
            .serverEnviroment()
            .flatMap { [weak self] serverEnvironment -> Observable<[String]> in
                
                guard let self = self else { return Observable.never() }
                
                return self.repositories
                    .matcherRepository
                    .settingsIdsPairs(serverEnvironment: serverEnvironment)
            }
            .flatMap { (pricePairs) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                
                let result = CorrectionPairsUseCaseLogic.mapCorrectPairs(settingsIdsPairs: pricePairs, pairs: pairs)
                return Observable.just(result)
            }
    }
}

fileprivate extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
