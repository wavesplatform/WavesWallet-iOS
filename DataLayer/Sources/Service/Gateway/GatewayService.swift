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
    
    enum Keys {
        static let sender = "sender"
    }
    
    enum Path {
        static let withdrawProcess = "v1/external/withdraw"
        static let depositProcess = "v1/external/deposit"
        static let send = "v1/external/send"
    }
}

enum Gateway {
    enum Service {
        case startWithdrawProcess(baseURL: URL, withdrawProcess: StartProcess)
        case startDepositProcess(baseURL: URL, depositProcess: StartProcess)
        case send(baseURL: URL, transaction: NodeService.Query.Transaction, accountAddress: String)
    }
    
    enum DTO {}
}

extension Gateway.DTO {
    
    struct Deposit: Decodable {
        let address: String
        let minAmount: Int64
        let maxAmount: Int64
    }
    
    struct Withdraw: Decodable {
        let recipientAddress: String
        let minAmount: Int64
        let maxAmount: Int64
        let fee: Int64
        let processId: String
    }
    
}

extension Gateway.Service {
    
    struct StartProcess: Codable {
        let userAddress: String
        let assetId: String
    }
}

extension Gateway.Service: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        
        switch self {
        case .startDepositProcess(let initProcess):
            return initProcess.baseURL

        case .startWithdrawProcess(let initProcess):
            return initProcess.baseURL
            
        case .send(let send):
            return send.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .startWithdrawProcess:
            return Constants.Path.withdrawProcess

        case .startDepositProcess:
            return Constants.Path.depositProcess
            
        case .send:
            return Constants.Path.send
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
        case .startWithdrawProcess(let initProcess):
            return .requestParameters(parameters: initProcess.withdrawProcess.dictionary, encoding: JSONEncoding.default)

        case .startDepositProcess(let initProcess):
            return .requestParameters(parameters: initProcess.depositProcess.dictionary, encoding: JSONEncoding.default)
            
        case .send(let send):
            
            var params = send.transaction.params
            params[Constants.Keys.sender] = send.accountAddress
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
}
