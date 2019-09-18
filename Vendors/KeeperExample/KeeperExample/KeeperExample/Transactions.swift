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

final class Transactions {
    
    struct Transaction {
        let name: String
        let type: NodeService.Query.Transaction
    }
    
    static var list: [Transaction] {
        
        return [.init(name: "Transfer", type: .transfer(txTansfer)),
                .init(name: "Invoke Script", type: .invokeScript(txInvokeScript)),
                .init(name: "Data", type: .data(txData)),
                .init(name: "Transfer Error", type: .transfer(txTransferError)),
                .init(name: "Invoke Script Error", type: .invokeScript(txInvokeScriptError)),
                .init(name: "Data empty", type: .data(txDataEmpty)),
                .init(name: "Data error", type: .data(txDataError)),
                .init(name: "Burn", type: .burn(txBurn))]
    }
    
    private static var chainId: String {
        return  WavesSDK.shared.enviroment.chainId
    }
}

extension WavesKeeper.Response {
    var jsonString: String? {

        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            return String(data: data, encoding: .utf8)
        }
      
        return nil
    }
}

extension NodeService.Query.Transaction {
    
    var jsonString: String? {
                
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
}

private extension Transactions {

    static var txTansfer: NodeService.Query.Transaction.Transfer {
        return .init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
                     assetId: "WAVES",
                     amount: 1000,
                     fee: 100000,
                     attachment: "First",
                     feeAssetId: "WAVES",
                     chainId: chainId)
    }
    
    static var txInvokeScript: NodeService.Query.Transaction.InvokeScript {
        let fee: Int64 = 900000
        let dApp: String = "3Mv9XDntij4ZRE1XiNZed6J74rncBpiYNDV"
        
        let arg1 = NodeService.Query.Transaction.InvokeScript.Arg(value: .string("Some string!"))
        let arg2 = NodeService.Query.Transaction.InvokeScript.Arg(value: .integer(128))
        let arg3 = NodeService.Query.Transaction.InvokeScript.Arg(value: .integer(-127))
        let arg4 = NodeService.Query.Transaction.InvokeScript.Arg(value: .bool(true))
        let arg5 = NodeService.Query.Transaction.InvokeScript.Arg(value: .bool(false))
        let arg6 = NodeService.Query.Transaction.InvokeScript.Arg(value: .binary("base64:VGVzdA=="))
        
        let queryModel = NodeService.Query.Transaction.InvokeScript(chainId: chainId,
                                                                    fee: fee,
                                                                    feeAssetId: "WAVES",
                                                                    dApp: dApp,
                                                                    call: .init(function: "testarg", args: [arg1, arg2, arg3,
                                                                                                            arg4, arg5, arg6]),
                                                                    payment: [.init(amount: 1, assetId: "WAVES")])
        return queryModel
    }
    
    static var txData: NodeService.Query.Transaction.Data {
        let fee: Int64 = 900000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let data = NodeService.Query.Transaction.Data.Value(key: "size", value: .integer(10))
        
        let data1 = NodeService.Query.Transaction.Data.Value(key: "name", value: .string("Maks"))
        
        let data2 = NodeService.Query.Transaction.Data.Value(key: "isMan", value: .boolean(true))
        
        let binary = WavesCrypto.shared.base64encode(input: "Hello!".toBytes)
        
        let data3 = NodeService.Query.Transaction.Data.Value(key: "secret", value: .binary(binary))
        
        let queryModel = NodeService.Query.Transaction.Data(fee: fee,
                                                            timestamp: timestamp,
                                                            senderPublicKey: "",
                                                            data: [data, data1, data2, data3],
                                                            chainId: chainId)
        return queryModel
    }
    
    static var txTransferError: NodeService.Query.Transaction.Transfer {
        return .init(recipient: "",
                     assetId: "WAVES",
                     amount: 1000,
                     fee: 100000,
                     attachment: "First",
                     feeAssetId: "WAVES",
                     chainId: chainId)
    }
    
    static var txInvokeScriptError: NodeService.Query.Transaction.InvokeScript {
        return NodeService.Query.Transaction.InvokeScript(chainId: chainId,
                                                          fee: 0,
                                                          timestamp: 0,
                                                          senderPublicKey: "",
                                                          feeAssetId: "WAVES",
                                                          dApp: "",
                                                          call: nil,
                                                          payment: [.init(amount: 1, assetId: "WAVES")])
    }
    
    static var txDataEmpty: NodeService.Query.Transaction.Data {
        let fee: Int64 = 900000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let queryModel = NodeService.Query.Transaction.Data(fee: fee,
                                                            timestamp: timestamp,
                                                            senderPublicKey: "",
                                                            data: [],
                                                            chainId: chainId)
        
        return queryModel
    }
    
    static var txDataError: NodeService.Query.Transaction.Data {
        let queryModel = NodeService.Query.Transaction.Data(fee: 0,
                                                            timestamp: 0,
                                                            senderPublicKey: "",
                                                            data: [],
                                                            chainId: chainId)
        return queryModel
    }
    
    static var txBurn: NodeService.Query.Transaction.Burn {
        let fee: Int64 = 500000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let queryModel = NodeService.Query.Transaction.Burn(chainId: chainId,
                                                            fee: fee,
                                                            assetId: "C5XD7iTdyx868yRE7DS9BmqonF1TBcM5W2hfTEWW5Dfm",
                                                            quantity: 1,
                                                            timestamp: timestamp,
                                                            senderPublicKey: "")
        return queryModel
    }
 
}
