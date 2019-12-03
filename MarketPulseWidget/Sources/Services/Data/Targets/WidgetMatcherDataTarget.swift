//
//  WidgetMatcherDataTarget.swift
//  MarketPulseWidget
//
//  Created by rprokofev on 03.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.

import Foundation
import Moya

private enum TargetConstants {
    static let rates = "rates"
    static let pairs = "pairs"
    static let matcher = "matchers"
}

extension WidgetDataService.Query {
    
    struct MatcherRates {
        
        struct Pair {
            let amountAssetId: String
            let priceAssetId: String
        }
        
        let pairs: [Pair]
        let matcher: String
    }
}

extension WidgetDataService.Target {

    struct MatcherRates {
        let query: WidgetDataService.Query.MatcherRates
        let dataUrl: URL
    }
}

extension WidgetDataService.Target.MatcherRates: WidgetDataTargetType {

    var path: String {
        return "\(TargetConstants.matcher)/\(String(describing: self.query.matcher))/\(TargetConstants.rates)"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {

        let paramenets: [String: Any] = {
           return [TargetConstants.pairs: query.pairs.map { $0.amountAssetId + "/" + $0.priceAssetId }]
        }()

        return .requestParameters(parameters: paramenets,
                                  encoding: JSONEncoding.default)
    }
}

