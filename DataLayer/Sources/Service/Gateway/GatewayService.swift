//
//  GavewayService.swift
//  InternalDataLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

enum Gateway {
    enum Service {}
    enum DTO {}
}

extension Gateway.DTO {
    
    struct Withdraw: Decodable {
        let recipientAddress: String
        let minAmount: Double
        let maxAmount: Double
        let fee: Double
        let processId: String
    }
}

extension Coinomat.Service {
    
    struct InitWithdraw: Codable {
        let userAddress: String
        let assetId: String
    }
}
extension Gateway.Service: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        return URL(string: "https://gw.wavesplatform.com/api/v1/external/withdraw")!
    }
    
    var path: String {
        return ""
//        switch self {
//        case .getRate(let rate):
//            return rate.path
//
//        case .cardLimit(let limit):
//            return limit.path
//
//        case .createTunnel(let tunnel):
//            return tunnel.path
//
//        case .getTunnel(let tunnel):
//            return tunnel.path
//
//        case .getPrice(let price):
//            return price.path
//        }
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        
        return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        
//        switch self {
//        case .getRate(let rate):
//            return .requestParameters(parameters: rate.dictionary, encoding: URLEncoding.default)
//            
//        case .cardLimit(let limit):
//            return .requestParameters(parameters: limit.dictionary, encoding: URLEncoding.default)
//            
//        case .createTunnel(let tunnel):
//            return .requestParameters(parameters: tunnel.dictionary, encoding: URLEncoding.default)
//            
//        case .getTunnel(let tunnel):
//            return .requestParameters(parameters: tunnel.dictionary, encoding: URLEncoding.default)
//            
//        case .getPrice(let price):
//            return .requestParameters(parameters: price.dictionary, encoding: URLEncoding.default)
//        }
    }
}
