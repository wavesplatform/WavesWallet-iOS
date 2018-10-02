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
        
        enum Status {
            case activeNow
            case unconfirmed
            case completed
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
            case spamReceived(Spam)
            case massSpamReceived(MassSpam)
            case data(Data)
            case unrecognisedTransaction
        }

        // Waves, BTC..
        let balance: Balance
        let conversionBalance: Balance
        
        let fee: Money
        
        let confirmations: Int 
        let height: Int
        
        let timestamp: TimeInterval
        let status: Status
        
        let kind: Kind
        let comment: String?
    }
    
    struct Recipient {
        let name: String?
        let address: String
    }
    
}

extension TransactionHistoryTypes.DTO.Transaction.Kind {
    
    struct ViewReceived {
        let from: TransactionHistoryTypes.DTO.Recipient
    }
    
    struct ViewSend {
        let to: TransactionHistoryTypes.DTO.Recipient
    }
    
    struct ViewLeasing {
        let to: TransactionHistoryTypes.DTO.Recipient
    }
    
    struct Exchange {
        let exchangeBalance: Money
        let exchangeCurrency: String
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
        let from: TransactionHistoryTypes.DTO.Recipient
    }
    
    struct IncomingLeasing {
        let from: TransactionHistoryTypes.DTO.Recipient
    }
    
    struct MassSend {
        let to: [TransactionHistoryTypes.DTO.Recipient]
    }
    
    struct MassReceived {
        let from: [TransactionHistoryTypes.DTO.Recipient]
    }
    
    struct Spam {
        let from:  TransactionHistoryTypes.DTO.Recipient
    }
    
    struct MassSpam {
        let from:  [TransactionHistoryTypes.DTO.Recipient]
    }
    
    struct Data {
        let data: String
    }
    
}

