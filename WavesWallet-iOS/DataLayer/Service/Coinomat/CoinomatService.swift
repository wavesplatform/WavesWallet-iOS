//
//  CoinomatSerive.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtension

private enum Constants {
    static let url = "https://coinomat.com/"
}

private enum Version: String {
    case v1 = "api/v1/"
    case v2 = "api/v2/"
}

private protocol ApiServicePath {
    var path: String { get }
}

enum Coinomat {

    enum Service {
        case getRate(Rate)
        case cardLimit(CardLimit)
        case createTunnel(CreateTunnel)
        case getTunnel(GetTunnel)
        case getPrice(Price)
    }
    
    static var addresses: [String] {
        return ["3PAs2qSeUAfgqSKS8LpZPKGYEjJKcud9Djr", // cryptocurrency
                "3P7qtv5Z7AMhwyvf5sM6nLuWWypyjVKb7Us", // fiat
                "3P2oLgTxQxNcLSEcSfqRvarpzcGVLCggftC"] // card
    }
    
    static var buyURL: String {
        return Constants.url + Version.v2.rawValue + "indacoin/buy.php"
    }
}

extension Coinomat.Service {
    
    struct Rate: Codable, ApiServicePath {
        let f: String
        let t: String
        
        init(from: String, to: String) {
            f = from
            t = to
        }
        
        var path: String {
            return Version.v1.rawValue + "get_xrate.php"
        }
    }
    
    struct CardLimit: Codable, ApiServicePath {
        
        let crypto: String
        let address: String
        let fiat: String
        
        var path: String {
            return Version.v2.rawValue + "indacoin/limits.php"
        }
    }

    struct CreateTunnel: Codable, ApiServicePath {
        
        let currency_from: String
        let currency_to: String
        let wallet_to: String
        let monero_payment_id: String?
        
        var path: String {
            return Version.v1.rawValue + "create_tunnel.php"
        }
    }
    
    struct GetTunnel: Codable, ApiServicePath {
        let xt_id: Int
        let k1: String
        let k2: String
        let history: Int = 0
        
        var path: String {
            return Version.v1.rawValue + "get_tunnel.php"
        }
    }
    
    struct Price: Codable, ApiServicePath {
        
        let crypto: String = GlobalConstants.wavesAssetId
        let fiat: String
        let address: String
        let amount: Double

        var path: String {
            return Version.v2.rawValue + "indacoin/rate.php"
        }
    }
}

extension Coinomat.Service: TargetType {
 
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        return URL(string: Constants.url)!
    }
    
    var path: String {
        
        switch self {
        case .getRate(let rate):
            return rate.path
        
        case .cardLimit(let limit):
            return limit.path
            
        case .createTunnel(let tunnel):
            return tunnel.path

        case .getTunnel(let tunnel):
            return tunnel.path
        
        case .getPrice(let price):
            return price.path
        }
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getRate(let rate):
            return .requestParameters(parameters: rate.dictionary, encoding: URLEncoding.default)
        
        case .cardLimit(let limit):
            return .requestParameters(parameters: limit.dictionary, encoding: URLEncoding.default)
            
        case .createTunnel(let tunnel):
            return .requestParameters(parameters: tunnel.dictionary, encoding: URLEncoding.default)
            
        case .getTunnel(let tunnel):
            return .requestParameters(parameters: tunnel.dictionary, encoding: URLEncoding.default)
        
        case .getPrice(let price):
            return .requestParameters(parameters: price.dictionary, encoding: URLEncoding.default)
        }
    }
}
