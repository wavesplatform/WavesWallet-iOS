//
//  PairsPathUseCaseProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public extension DomainLayer.DTO {
    enum CorrectionPairs {
       
        public struct Pair: Equatable, Hashable {
            public let amountAsset: String
            public let priceAsset: String
            
            public init(amountAsset: String, priceAsset: String) {
                self.amountAsset = amountAsset
                self.priceAsset = priceAsset
            }
        }
    }
}

public protocol CorrectionPairsUseCaseProtocol {    
    func correction(pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]>
}
