//
//  DexPairsApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension API.Service {
    
    struct ListPairs {
        let pairs: [API.DTO.Pair]
        let environment: Environment
    }
}


extension API.Service.ListPairs: BaseTargetType {

    private enum Constants {
        static let pairsPath = "/v0/pairs"
    }
    
    var path: String {
        return ""
    }
    
    var baseURL: URL {
        return URL(string: baseUrlString + parametersString)!
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
}

private extension API.Service.ListPairs {
    
    var baseUrlString: String {
        return environment.servers.dataUrl.relativeString + Constants.pairsPath
    }
    
    var parametersString: String {
        
        var url = ""
        
        for pair in pairs {
            if (url as NSString).range(of: "?").location == NSNotFound {
                url.append("?")
            }
            if url.last != "?" {
                url.append("&")
            }
            url.append("pairs=" + pair.amountAsset + "/" + pair.priceAsset)
        }

        return url
    }
}
