//
//  TransactionHistoryTypes+DTO.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension TransactionHistoryTypes.DTO {
    
    struct Transaction: Mutating {
        
        enum Status: String {
            case activeNow = "ACTIVE NOW"
            case unconfirmed = "UNCONFIRMED"
            case completed = "COMPLETED"
        }
        
        enum Kind {
            case viewReceived(ViewReceived)
            case viewSend(ViewSend)
            case viewLeasing(ViewLeasing)
            case exchange(Exchange)
            case selfTranserred(SelfTransferred)
            case tokenGeneration(TokenGeneration)
            case tokenReissue(TokenReissue)
            case tokenBurning(TokenBurning)
            case createdAlias(CreatedAlias)
            case canceledLeasing(CanceledLeasing)
            case incomingLeasing(IncomingLeasing)
            case massSend(MassSend)
            case massReceived(MassReceived)
        }
        
        let fee: Money
        let confirmations: Int
        let block: Int
        let timestamp: TimeInterval
        let status: Status
        let kind: Kind
        let comment: String?
    }
    
}

extension TransactionHistoryTypes.DTO.Transaction.Kind {
    
    struct ViewReceived {
        let from: TransactionHistoryTypes.ViewModel.Recipient
    }
    
    struct ViewSend {
        let to: TransactionHistoryTypes.ViewModel.Recipient
    }
    
    struct ViewLeasing {
        let to: TransactionHistoryTypes.ViewModel.Recipient
    }
    
    struct Exchange {
        let BTCPrice: Money
    }
    
    struct SelfTransferred {
        
    }
    
    struct TokenGeneration {
        let id: String
        let reissuable: Bool
    }
    
    struct TokenReissue {
        let id: String
        let reissuable: Bool
    }
    
    struct TokenBurning {
        let id: String
    }
    
    struct CreatedAlias {
        
    }
    
    struct CanceledLeasing {
        let from: TransactionHistoryTypes.ViewModel.Recipient
    }
    
    struct IncomingLeasing {
        let from: TransactionHistoryTypes.ViewModel.Recipient
    }
    
    struct MassSend {
        let to: [TransactionHistoryTypes.ViewModel.Recipient]
    }
    
    struct MassReceived {
        let from: [TransactionHistoryTypes.ViewModel.Recipient]
    }
    
}

extension TransactionHistoryTypes.DTO.Transaction {
    
    static func map(from transactions: [HistoryTypes.DTO.Transaction]) -> [TransactionHistoryTypes.DTO.Transaction] {
        
        return transactions.map({ (transaction) -> TransactionHistoryTypes.DTO.Transaction in
            
            return TransactionHistoryTypes.DTO.Transaction(fee: Money(110, 0), confirmations: 3525, block: 324, timestamp: 321901305, status: .completed, kind: .viewReceived(.init(from: TransactionHistoryTypes.ViewModel.Recipient(name: "Привет", address: "x4Jjksd#jkl$klssd"))), comment: "Комментарий")
            
        })
        
    }
    
}
