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

//@POST("gateways/api.DispatcherManagingPublic/GetOrCreateTransferBinding")
//fun transferBinding(@Header("Authorization") token: String,
//                    @Body request: TransferBindingRequest): Observable<TransferBindingResponse>

enum WEGateway {
    enum Service {
        case transferBinding(baseURL: URL, query: WEGateway.Query.TransferBinding)
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
}

extension WEGateway.Service: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        
        switch self {
        case .transferBinding(let baseURL, _):
            return baseURL
        }
    }
    
    var path: String {
        switch self {
        case .transferBinding:
            return "api.DispatcherManagingPublic/GetOrCreateTransferBinding"
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = ContentType.applicationJson.headers
        
        switch self {
        case .transferBinding(_, let token):
            headers["Authorization"] = token.token
        }
        
        return headers
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .transferBinding(_, let token):
            return .requestJSONEncodable(token)
        }
    }
}

