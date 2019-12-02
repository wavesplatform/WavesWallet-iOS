//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

extension WidgetDataService.Target {

    struct Transactions {
        enum Kind {
            case getExchangeWithFilters(DataService.Query.ExchangeFilters)
        }
        
        let kind: Kind
        let dataUrl: URL
        let matcher: String?
    }
}

extension WidgetDataService.Target.Transactions: WidgetDataTargetType {

    private enum Constants {
        static let exchange = "transactions/exchange"
        static let matcher = "matcher"
    }

    var path: String {
        switch kind {

        case .getExchangeWithFilters:
            return Constants.exchange
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getExchangeWithFilters:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getExchangeWithFilters(let filter):
            
            var dictionary = filter.dictionary
            
            if let matcher = self.matcher {
                dictionary[Constants.matcher] = matcher
            }
            
            return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
        }
    }
}
