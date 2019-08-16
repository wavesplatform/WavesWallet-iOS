//
//  CorrectionPairsUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKCrypto

//TODO: Testing!
final class CorrectionPairsUseCase: CorrectionPairsUseCaseProtocol {
    
    private let repositories: RepositoriesFactoryProtocol
    private let useCases: UseCasesFactoryProtocol
    
    init(repositories: RepositoriesFactoryProtocol, useCases: UseCasesFactoryProtocol) {
        self.repositories = repositories
        self.useCases = useCases
    }
    
    func correction(pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> {
        
        let pairs = repositories
            .matcherRepository
            .settingsIdsPairs()
            .flatMap { (pricePairs) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                
                let result = pairs.map({ (pair) -> DomainLayer.DTO.CorrectionPairs.Pair in
                    
                    let amounIndex = pricePairs.firstIndex(of: pair.amountAsset)
                    let priceIndex = pricePairs.firstIndex(of: pair.priceAsset)
                    
                    var amount: String! = nil
                    var price: String! = nil
                    
                    if let amounIndex = amounIndex, let priceIndex = priceIndex {
                        if amounIndex > priceIndex {
                            price = pair.priceAsset
                            amount = pair.amountAsset
                        } else {
                            price = pair.amountAsset
                            amount = pair.priceAsset
                        }
                    } else if amounIndex != nil && priceIndex == nil {
                        price = pair.amountAsset
                        amount = pair.priceAsset
                    } else if priceIndex != nil && amounIndex == nil {
                        price = pair.priceAsset
                        amount = pair.amountAsset
                    } else {
                        let amountBytes: [UInt8] = WavesCrypto.shared.base58decode(input: pair.amountAsset) ?? []
                        let priceBytes: [UInt8] = WavesCrypto.shared.base58decode(input: pair.priceAsset) ?? []
                        
                        if amountBytes.elementsEqual(priceBytes) {
                            price = pair.amountAsset
                            amount = pair.priceAsset
                        } else {
                            price = pair.priceAsset
                            amount = pair.amountAsset
                        }
                    }
                    
                    return DomainLayer.DTO.CorrectionPairs.Pair.init(amountAsset: amount,
                                                                     priceAsset: price)
                })
                
                return Observable.just(result)
            }
        
        return pairs
    }
}
