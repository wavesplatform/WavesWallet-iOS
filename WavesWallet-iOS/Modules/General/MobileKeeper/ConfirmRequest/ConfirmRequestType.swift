//
//  ConfirmRequestType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDK
import WavesSDKCrypto
import Extensions
import DomainLayer

enum ConfirmRequest {
    
    enum DTO {
        struct Input {
            let request: DomainLayer.DTO.MobileKeeper.Request
            let signedWallet: SignedWallet
        }
    }
    
    struct State {
        
        struct UI: DataSourceProtocol {
            
            enum Action {
                case none
                case update
                case closeRequest
            }
            
            var sections: [Section]
            var action: Action
        }
        
        struct Core {
            
            enum Action {
                case prepareRequest
                case loadingAssets
                case none
            }
            
            var action: Action
            var request: DomainLayer.DTO.MobileKeeper.Request
            var signedWallet: SignedWallet
            var prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest?
            var complitingRequest: ConfirmRequest.DTO.ComplitingRequest?
            var timestamp: Date
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case none
        case viewDidAppear
        case handlerError
        case prepareRequest([Asset], DomainLayer.DTO.MobileKeeper.PrepareRequest)
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

    struct ComplitingRequest {
        let transaction: Transaction
        let prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest
        let signedWallet: SignedWallet
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
        let asset: Asset
        let amount: Money
        
        let feeAsset: Asset
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
        let feeAsset: Asset
        let data: [Value]
        let chainId: String
    }
    
    struct InvokeScript {
        struct Arg {
            enum Value {
                case bool(Bool) //boolean
                case integer(Int64) // integer
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
            let asset: Asset
        }
        
        let asset: Asset
        let fee: Money
        let feeAsset: Asset
        let chainId: String
        let dApp: String
        let call: Call?
        let payment: [Payment]
    }
}
