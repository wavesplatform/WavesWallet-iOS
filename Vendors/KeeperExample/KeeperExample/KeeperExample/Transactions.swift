//
//  Transactions.swift
//  KeeperExample
//
//  Created by Pavel Gubin on 05.09.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import Foundation
import WavesSDK
import WavesSDKCrypto

extension ViewController {
    
    func txTansfer(chainId: String) -> NodeService.Query.Transaction.Transfer {
        return .init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
              assetId: "WAVES",
              amount: 1000,
              fee: 100000,
              attachment: "First",
              feeAssetId: "WAVES",
              chainId: chainId)
    }
    
    func txInvokeScript(chainId: String) -> NodeService.Query.Transaction.InvokeScript {
        let fee: Int64 = 900000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        let dApp: String = "3Mv9XDntij4ZRE1XiNZed6J74rncBpiYNDV"
        
        let arg1 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .string("Some string!"))
        let arg2 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .integer(128))
        let arg3 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .integer(-127))
        let arg4 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .bool(true))
        let arg5 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .bool(false))
        let arg6 = NodeService.Query.Transaction.InvokeScript.Arg.init(value: .binary("base64:VGVzdA=="))
        
        var queryModel = NodeService.Query.Transaction.InvokeScript.init(chainId: chainId,
                                                                         fee: fee,
                                                                         timestamp: timestamp,
                                                                         senderPublicKey: "",
                                                                         feeAssetId: "WAVES",
                                                                         dApp: dApp,
                                                                         call: .init(function: "testarg", args: [arg1, arg2, arg3,
                                                                                                                 arg4, arg5, arg6]),
                                                                         payment: [.init(amount: 1, assetId: "WAVES")])
        return queryModel
    }
    
    func txData(chainId: String) -> NodeService.Query.Transaction.Data {
        let fee: Int64 = 900000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let data = NodeService.Query.Transaction.Data.Value.init(key: "size", value: .integer(10))
        
        let data1 = NodeService.Query.Transaction.Data.Value.init(key: "name", value: .string("Maks"))
        
        let data2 = NodeService.Query.Transaction.Data.Value.init(key: "isMan", value: .boolean(true))
        
        let binary = WavesCrypto.shared.base64encode(input: "Hello!".toBytes)
        
        let data3 = NodeService.Query.Transaction.Data.Value.init(key: "secret", value: .binary(binary))
        
        var queryModel = NodeService.Query.Transaction.Data.init(fee: fee,
                                                                 timestamp: timestamp,
                                                                 senderPublicKey: "",
                                                                 data: [data, data1, data2, data3],
                                                                 chainId: chainId)
        return queryModel
    }
    
    func txTransferError(chainId: String) -> NodeService.Query.Transaction.Transfer {
        return .init(recipient: "",
                     assetId: "WAVES",
                     amount: 1000,
                     fee: 100000,
                     attachment: "First",
                     feeAssetId: "WAVES",
                     chainId: chainId)
    }
    
    
    func txInvokeScriptError(chainId: String) -> NodeService.Query.Transaction.InvokeScript {
        var queryModel = NodeService.Query.Transaction.InvokeScript.init(chainId: chainId,
                                                                         fee: 0,
                                                                         timestamp: 0,
                                                                         senderPublicKey: "",
                                                                         feeAssetId: "WAVES",
                                                                         dApp: "",
                                                                         call: nil,
                                                                         payment: [.init(amount: 1, assetId: "WAVES")])
        return queryModel
    }
    
    func txDataEmpty(chainId: String) -> NodeService.Query.Transaction.Data {
        let fee: Int64 = 900000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        var queryModel = NodeService.Query.Transaction.Data.init(fee: fee,
                                                                 timestamp: timestamp,
                                                                 senderPublicKey: "",
                                                                 data: [],
                                                                 chainId: chainId)
        
        return queryModel
    }
    
    func txDataError(chainId: String) -> NodeService.Query.Transaction.Data {
        var queryModel = NodeService.Query.Transaction.Data.init(fee: 0,
                                                                 timestamp: 0,
                                                                 senderPublicKey: "",
                                                                 data: [],
                                                                 chainId: chainId)
        return queryModel
    }
    
    func txBurn(chainId: String) -> NodeService.Query.Transaction.Burn {
        let fee: Int64 = 500000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        var queryModel = NodeService.Query.Transaction.Burn.init(chainId: chainId,
                                                                 fee: fee,
                                                                 assetId: "C5XD7iTdyx868yRE7DS9BmqonF1TBcM5W2hfTEWW5Dfm",
                                                                 quantity: 1,
                                                                 timestamp: timestamp,
                                                                 senderPublicKey: "")
        return queryModel
    }
}
