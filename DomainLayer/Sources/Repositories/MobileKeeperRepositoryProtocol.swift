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
        public let id: String
        
        public init(dApp: Application,
                    action: Action,
                    transaction: TransactionSenderSpecifications,
                    id: String) {
            self.dApp = dApp
            self.action = action
            self.transaction = transaction
            self.id = id
        }
    }
    
    enum Success {
        case sign(TransactionSenderSpecifications)
        case send(DomainLayer.DTO.AnyTransaction)
    }
    
    enum Error {
        case reject
        case message(String, Int)
    }
    
    struct Response {
        public enum Kind {
            case error(Error)
            case success(Success)
        }
        
        public let requestId: String
        public let kind: Kind

        public init(requestId: String, kind: Kind) {
            self.requestId = requestId
            self.kind = kind
        }
    }

    
    struct CompletedRequest {
        public let request: Request
        public let timestamp: Date
        public let proof: Bytes
        public let txId: String
        public let publicKey: String
        public let response: Response
        
        public init(request: Request, timestamp: Date, proof: Bytes, txId: String, publicKey: String, response: Response) {
            self.request = request
            self.timestamp = timestamp
            self.proof = proof
            self.txId = txId
            self.response = response
            self.publicKey = publicKey
        }
    }
    
    struct PrepareRequest {
        public let request: Request
        public let timestamp: Date
        public let proof: Bytes
        public let txId: String
        public let signedWallet: DomainLayer.DTO.SignedWallet
        
        public init(request: Request, timestamp: Date, proof: Bytes, txId: String, signedWallet: DomainLayer.DTO.SignedWallet) {
            self.request = request
            self.timestamp = timestamp
            self.proof = proof
            self.txId = txId
            self.signedWallet = signedWallet
        }
    }
}

public enum MobileKeeperUseCaseError: Error {
    case none
    case dAppDontOpen
    case transactionDontSupport
    case dataIncorrect
}

public protocol MobileKeeperRepositoryProtocol {
    
    
    func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                        signedWallet: DomainLayer.DTO.SignedWallet,
                        timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest>
    
    func completeRequest(_ prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest>
    
    func decodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?>
    
    func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) -> Observable<Bool>
    
    func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request) -> Observable<Bool>
}
