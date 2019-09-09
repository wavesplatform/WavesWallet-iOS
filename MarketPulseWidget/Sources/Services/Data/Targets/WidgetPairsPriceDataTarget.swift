//
//  DexPairsApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

private enum TargetConstants {
    static let pairs = "pairs"
}

extension WidgetDataService.Query {
    
    struct PairsPrice {
        
        struct Pair {
            let amountAssetId: String
            let priceAssetId: String
        }
        
        let pairs: [Pair]
    }
    
    struct PairsPriceSearch {
        
        enum Kind {
            case byAsset(String)
            case byAssets(firstName: String, secondName: String)
        }
        
        let kind: Kind
    }
}

extension WidgetDataService.Target {
    
    struct PairsPrice {
        let query: WidgetDataService.Query.PairsPrice
        let dataUrl: URL
    }
    
    struct PairsPriceSearch {
        let kind: WidgetDataService.Query.PairsPriceSearch.Kind
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
        return .requestParameters(parameters: [TargetConstants.pairs: query.pairs.map { $0.amountAssetId + "/" + $0.priceAssetId } ],
                                  encoding: URLEncoding.default)
    }
}

extension WidgetDataService.Target.PairsPriceSearch: WidgetDataTargetType {
    
    private enum Constants {
        static let searchByAsset = "search_by_asset"
        static let searchByAssets = "search_by_assets"

    }
    
    var path: String {
        return TargetConstants.pairs
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch kind {
        case .byAsset(let name):
            return .requestParameters(parameters: [Constants.searchByAsset: name], encoding: URLEncoding.default)
            
        case .byAssets(let firstName, let secondName):
            return .requestParameters(parameters: [Constants.searchByAssets: firstName + "," + secondName],
                                      encoding: URLEncoding.default)
        }
    }
}
