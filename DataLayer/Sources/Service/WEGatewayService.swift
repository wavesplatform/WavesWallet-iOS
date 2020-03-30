//
//  WEGatewayService.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

enum WEGateway {
    enum Service {
        case transferBinding(baseURL: URL, query: WEGateway.Query.TransferBinding)
        case adCashDepositsRegisterOrder(baseURL: URL, token: String, query: WEGateway.Query.AdCashDepositsRegisterOrder)
    }
    
    enum Query {}
}

extension WEGateway.Query {
    struct TransferBinding: Codable {
        let token: String
        let senderAsset: String
        let recipientAsset: String
        let recipientAddress: String
        
        private enum CodingKeys: String, CodingKey {
            case token
            case senderAsset = "sender_asset"
            case recipientAsset = "recipient_asset"
            case recipientAddress = "recipient_address"
        }
    }
    
    struct AdCashDepositsRegisterOrder: Codable {
        let currency: String
        let amount: String
        let address: String
    }
}

extension WEGateway.Service: TargetType {
    var sampleData: Data { Data() }
    
    var baseURL: URL {
        switch self {
        case .transferBinding(let baseURL, _):
            return baseURL
            
        case .adCashDepositsRegisterOrder(let baseURL, _, _):
            return baseURL
        }
    }
    
    var path: String {
        switch self {
        case .transferBinding:
            return "api.DispatcherManagingPublic/GetOrCreateTransferBinding"
        case .adCashDepositsRegisterOrder:
            return "acash.ACashDeposits/RegisterOrder"
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = ContentType.applicationJson.headers
        
        switch self {
        case .transferBinding(_, let query):
            headers["Authorization"] = query.token
            
        case .adCashDepositsRegisterOrder(_, let token, _):
            headers["Authorization"] = token
        }
        
        return headers
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .transferBinding(_, let query):
            return .requestJSONEncodable(query)
            
        case .adCashDepositsRegisterOrder(_, _, let query):
            return .requestJSONEncodable(query)
        }
    }
}
