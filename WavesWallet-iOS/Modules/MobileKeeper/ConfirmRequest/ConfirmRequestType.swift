//
//  ConfirmRequestType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import WavesSDKCrypto
import Extensions
import DomainLayer

enum ConfirmRequest {
    
    enum DTO {
        struct Input {
            let data: WavesKeeper.Data
            let signedWallet: DomainLayer.DTO.SignedWallet
        }
    }
    
    struct State {
        
        struct UI: DataSourceProtocol {
            
            enum Action {
                case none
                case update
            }
            
            var sections: [Section]
            var action: Action
        }
        
        struct Core {
            
            enum Action {
                case prepareRequest
                case none
            }
            
            var action: Action
            var data: WavesKeeper.Data
            var signedWallet: DomainLayer.DTO.SignedWallet
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case none
        case viewDidAppear
        case prepareRequest([DomainLayer.DTO.Asset])
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
    }
    
    enum Row {
        case transactionKind(ConfirmRequestTransactionKindCell.Model)
        case fromTo(ConfirmRequestFromToCell.Model)
        case keyValue(ConfirmRequestKeyValueCell.Model)
        case feeAndTimestamp(ConfirmRequestFeeAndTimestampCell.Model)
        case balance(ConfirmRequestBalanceCell.Model)
        case skeleton
        case buttons
    }
}


/*
    Transfer from URL -> ConfirmRequest.DTO.Transfer + Wallet +
        + Timestamp + Proof + TXID -> ConfirmRequest.DTO.Request
                

*/


extension ConfirmRequest.DTO {

    struct PrepareRequest {
        let transaction: Transaction
        let data: WavesKeeper.Data
        let signedWallet: DomainLayer.DTO.SignedWallet
        let timestamp: Date
    }
    
    struct Request {
        let transaction: Transaction
        let data: WavesKeeper.Data
        let signedWallet: DomainLayer.DTO.SignedWallet
        let timestamp: Date
        let proof: Bytes
        let txId: String
    }
    
    enum Transaction {
        case transfer(Transfer)
        case data(Data)
        case invokeScript(InvokeScript)
    }
    
    
    struct Transfer {
        let recipient: String
        let asset: DomainLayer.DTO.Asset
        let amount: Money
        
        let feeAsset: DomainLayer.DTO.Asset
        let fee: Money
        
        let attachment: String
        let chainId: String
    }

    struct Data {
        struct Value {
            enum Kind {
                case integer(Int64)
                case boolean(Bool)
                case string(String)
                case binary(Base64)
            }
            
            let key: String
            let value: Kind
        }
        
        let fee: Money
        let feeAsset: DomainLayer.DTO.Asset
        let data: [Value]
        let chainId: String
        
    }
    
    struct InvokeScript {
        struct Arg {
            enum Value {
                case bool(Bool) //boolean
                case integer(Int) // integer
                case string(String) // string
                case binary(String) // binary
            }
            
            let value: Value
        }
        
        struct Call {
            let function: String
            let args: [Arg]
            
            init(function: String, args: [Arg]) {
                self.function = function
                self.args = args
            }
        }
        
        struct Payment {
            let amount: Money
            let asset: DomainLayer.DTO.Asset
        }
        
        let asset: DomainLayer.DTO.Asset
        let fee: Money
        let feeAsset: DomainLayer.DTO.Asset
        let chainId: String
        let dApp: String
        let call: Call?
        let payment: [Payment]
    }
}
