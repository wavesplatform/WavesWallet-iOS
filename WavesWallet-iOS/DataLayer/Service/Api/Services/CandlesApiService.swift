//
//  CandlesApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtension
import WavesSDKCrypto

extension API.Service {

    struct Candles {
        let amountAsset: String
        let priceAsset: String
        let params: API.Query.CandleFilters
        let environment: Environment
    }
}

extension API.Service.Candles: BaseTargetType {
    
    var path: String {
        return "/candles/\(amountAsset)/\(priceAsset)"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestParameters(parameters: params.dictionary, encoding: URLEncoding.default)
    }
    
    var baseURL: URL {
        return URL(string: environment.servers.dataUrl.relativeString)!
    }
    
}
