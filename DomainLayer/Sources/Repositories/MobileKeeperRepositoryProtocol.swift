//
//  MobileKeeperRepositoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKCrypto

public extension DomainLayer.DTO {
    enum MobileKeeper {}
}

public extension DomainLayer.DTO.MobileKeeper {
    
    struct Application {
        public let name: String
        public let iconUrl: String
        public let scheme: String
        
        public init(name: String, iconUrl: String, scheme: String) {
            self.name = name
            self.iconUrl = iconUrl
            self.scheme = scheme
        }
    }
    
    enum Action {
        case sign
        case send
    }
    
    struct Request {
        public let dApp: Application
        public let action: Action
        public let transaction: TransactionSenderSpecifications
        
        public init(dApp: Application,
                    action: Action,
                    transaction: TransactionSenderSpecifications) {
            self.dApp = dApp
            self.action = action
            self.transaction = transaction
        }
    }
    
    enum Success {
        case transactionQuery
        case transaction(DomainLayer.DTO.AnyTransaction)
    }
    
    enum Error {
        case reject
        case message(String, Int)
    }
    
    enum Response {
        case error(Error)
        case success(Success)
    }
    
    struct CompletedRequest {
        public let request: Request
        public let timestamp: Date
        public let proof: Bytes
        public let txId: String
        public let response: Response

        public init(request: Request, timestamp: Date, proof: Bytes, txId: String, response: Response) {
            self.request = request
            self.timestamp = timestamp
            self.proof = proof
            self.txId = txId
            self.response = response
        }
    }
    
    struct PrepareRequest {
        public let request: Request
        public let timestamp: Date
        public let proof: Bytes
        public let txId: String
        
        public init(request: Request, timestamp: Date, proof: Bytes, txId: String) {
            self.request = request
            self.timestamp = timestamp
            self.proof = proof
            self.txId = txId
        }
    }
}

public protocol MobileKeeperRepositoryProtocol {
    
    
    func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                        signedWallet: DomainLayer.DTO.SignedWallet,
                        timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest>
    
    func completeRequest(_ prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest>
    
    func docodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?>
    
    func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest)
    
    func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request)
}


/*
 
 
 UI -> MobileKeeper ->

 
 Урлу получу и отдаю в репозиторию получаю MobileKeeper.Request потом собираю данные и возвращаю DomainLayer.DTO.Request
 URL -> Repository -> MobileKeeper.Request -> DomainLayer.DTO.Request (A)
 
 Пользователь отправляет Request либо отменяет и получает результат
 DomainLayer.DTO.Request -> Repository -> Send or Sign -> DomainLayer.DTO.Response
 
 Пользователь возвращает ответ в DApp
 DomainLayer.DTO.Response -> MobileKeeper.Response

 
 A) MobileKeeper - Request -> DomainLayer.DTO.Request

 B) DomainLayer.DTO.Response ->  MobileKeeper.Response
 
 
 */
