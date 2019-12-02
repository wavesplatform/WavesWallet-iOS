//
//  DexPairsApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/25/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya

private enum TargetConstants {
    static let pairs = "pairs"
    static let matcher = "matcher"
}

extension WidgetDataService.Query {
    
    struct PairsPrice {
        
        struct Pair {
            let amountAssetId: String
            let priceAssetId: String
        }
        
        let pairs: [Pair]
        let matcher: String?
    }

}

extension WidgetDataService.Target {
    
    struct PairsPrice {
        let query: WidgetDataService.Query.PairsPrice
        let dataUrl: URL
    }
}

extension WidgetDataService.Target.PairsPrice: WidgetDataTargetType {

    var path: String {
        return TargetConstants.pairs
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        
        let paramenets: [String: Any] = {
           
            if let matcher = self.query.matcher {
                return [TargetConstants.pairs: query.pairs.map { $0.amountAssetId + "/" + $0.priceAssetId },
                        TargetConstants.matcher: matcher]
            } else {
                return [TargetConstants.pairs: query.pairs.map { $0.amountAssetId + "/" + $0.priceAssetId } ]
            }
            
        }()
        
        return .requestParameters(parameters: paramenets,
                                  encoding: URLEncoding.default)
    }
}
