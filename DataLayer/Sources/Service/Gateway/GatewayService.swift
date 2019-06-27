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

private enum Constants {
    static let url = "https://gw.wavesplatform.com/api/"
}

enum Gateway {
    enum Service {
        case initProcess(InitProcess)
    }
    
    enum DTO {}
}

extension Gateway.DTO {
    
    struct Withdraw: Decodable {
        let recipientAddress: String
        let minAmount: Int64
        let maxAmount: Int64
        let fee: Int64
        let processId: String
    }
}

extension Gateway.Service {
    
    struct InitProcess: Codable {
        let userAddress: String
        let assetId: String
    }
}

extension Gateway.Service: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        return URL(string: Constants.url)!
    }
    
    var path: String {
        switch self {
        case .initProcess:
            return "v1/external/withdraw"
        }
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .initProcess(let initProcess):
            return .requestParameters(parameters: initProcess.dictionary, encoding: JSONEncoding.default)
        }
    }
}
