//
//  MobileKeeperRepositoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

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
    
    struct CompletingRequest {
        public let request: Request
        public let signedWallet: DomainLayer.DTO.SignedWallet
        public let timestamp: Date
    }
    
    
    
    
//    public func decodableData(_ url: URL, sourceApplication: String) -> Data? {
//
//        return Data.init(dApp: .init(name: "Test",
//                                     iconUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdF37xBUCZDiNuteNQRfQBTadMGcv25qpDRir40U5ILLYXp7uL", scheme: ""),
//                         action: .send,
//                         transaction: .send(.init(recipient: "3P5r1EXZwxJ21f3T3zvjx61RtY52QV4fb18",
//                                                  assetId: "WAVES",
//                                                  amount: 1000,
//                                                  fee: 10000,
//                                                  attachment: "",
//                                                  feeAssetID: "WAVES",
//                                                  chainId: "W")))
//    }
//
//
}

//

public protocol MobileKeeperRepositoryProtocol {
    
    func completeRequest(_ request: DomainLayer.DTO.MobileKeeper.CompletingRequest) -> Observable<Bool>
    
    func docodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?>
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
