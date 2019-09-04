//
//  MobileKeeperRepository.swift
//  DataLayer
//
//  Created by rprokofev on 01.09.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDK
import WavesSDKCrypto

//Rename to UseCase

public class MobileKeeperRepository: MobileKeeperRepositoryProtocol {
    
    private var repositoriesFactory: RepositoriesFactoryProtocol
    
    init(repositoriesFactory: RepositoriesFactoryProtocol) {
        self.repositoriesFactory = repositoriesFactory
        
        WavesKeeper.initialization(application: .init(name: "Waves",
                                                      iconUrl: "",
                                                      schemeUrl: "waves"))
    }
    public func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                               signedWallet: DomainLayer.DTO.SignedWallet,
                               timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest> {
        
        
        guard let signature = request.transactionSignature(signedWallet: signedWallet,
                                                           timestamp: timestamp) else {
                                                            //TODO: Error
            return Observable.never()
        }
        
        let prepareRequest = DomainLayer
            .DTO
            .MobileKeeper
            .PrepareRequest.init(request: request,
                                 timestamp: timestamp,
                                 proof: signature.bytesStructure,
                                 txId: signature.id,
                                 signedWallet: signedWallet)
        
        return Observable.just(prepareRequest)
    }
    
    public func completeRequest(_ prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> {
        
        let action = prepareRequest.request.action
        
        switch action {
        case .send:
            
            return repositoriesFactory
                .transactionsRepositoryRemote
                .send(by: prepareRequest.request.transaction,
                      wallet: prepareRequest.signedWallet)
                .flatMap({ (tx) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in
                    
                    let completedRequest = prepareRequest.completedRequest(response: .success(.send(tx)),
                                                                           signedWallet: prepareRequest.signedWallet)
                    return Observable.just(completedRequest)
                })
                .catchError({ (error) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in
                    
                    if let networkError = error as? NetworkError {
                        
                        let title = { () -> String in
                            switch networkError {
                            case .message(let message):
                                return message
                            default:
                                return ""
                            }
                        }()
                        
                        let completedRequest = prepareRequest.completedRequest(response: .error(.message(title, 0)),
                                                                               signedWallet: prepareRequest.signedWallet)
                        return Observable.just(completedRequest)
                    }
                    
                    let completedRequest = prepareRequest.completedRequest(response: .error(.reject),
                                                                           signedWallet: prepareRequest.signedWallet)
                    return Observable.just(completedRequest)
                })
            
        case .sign:
            
            let completedRequest = prepareRequest.completedRequest(response: .success(.sign(prepareRequest.request.transaction)),
                                                                   signedWallet: prepareRequest.signedWallet)
            return Observable.just(completedRequest)
        }
    }
    
    
    public func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) {
        
        returnResponse(for: completedRequest.request.dApp,
                       completedRequest: completedRequest)
    }
    
    public func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request) {
        
        returnError(for: request.dApp,
                    error: .reject)
    }
    
    public func decodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?> {
        
        guard let request: WavesKeeper.Request = self.decodableKeeperRequest(url, sourceApplication: sourceApplication) else {
            return Observable.just(nil)
        }
        
        guard let transactionSenderSpecifications = request.transaction.transactionSenderSpecifications else {
            return Observable.just(nil)
        }
        
        let mobileKeeperRequest = DomainLayer
            .DTO
            .MobileKeeper
            .Request
            .init(dApp: .init(name: request.dApp.name,
                              iconUrl: request.dApp.iconUrl,
                              scheme: request.dApp.schemeUrl),
                  action: (request.action == .send ? .send : .sign),
                  transaction: transactionSenderSpecifications)
        
        return Observable.just(mobileKeeperRequest)
    }
    
    //TODO: Pavel
    //TODO: Method For Wallet. Result Return for dApp
    public func returnError(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                            error: DomainLayer.DTO.MobileKeeper.Error) {
        
        let wavesKeeperReponse: WavesKeeper.Response = .error(error.wavesKeeperError)
        let wavesKeeperApplication = dApp.wavesKeeperApplication
        
        //Open DApp
    }
    
    public func returnResponse(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                              completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) {
        
        
        let wavesKeeperApplication = dApp.wavesKeeperApplication
        
        
    }
    
    //TODO: Pavel
    //TODO: Method For Wallet
    //TODO: URL парсим в -> Request
    public func decodableKeeperRequest(_ url: URL, sourceApplication: String) -> WavesKeeper.Request? {
        

        var request = WavesKeeper.Request.init(dApp: .init(name: "AppCon",
                                               iconUrl: "",
                                               schemeUrl: "AplicationMega"),
                                   action: .sign,
                                   transaction: .transfer(.init(recipient: "3PEsVWBVi4szBuJFTJ1dhYmULS4eH22sEUH",
                                                                assetId: "WAVES",
                                                                amount: 1000,
                                                                fee: 100000,
                                                                attachment: "",
                                                                feeAssetId: "WAVES",
                                                                chainId: "W")))
        
        return request
    }
}
    

fileprivate extension DomainLayer.DTO.MobileKeeper.Application {
    
    var wavesKeeperApplication: WavesKeeper.Application {
        return .init(name: name, iconUrl: iconUrl, schemeUrl: scheme)
    }
}

extension DomainLayer.DTO.MobileKeeper.CompletedRequest {
 
    var wavesKeeperReponse: WavesKeeper.Response? {
        
        guard case let .success(result) = self.response else { return nil }
        
        switch result {
        case .send(let model):
            guard let tx = model.transactionNodeService else { return nil }
            
            return .success(.send(tx))
            
        case .sign(let model):
            
            guard let tx = model.nodeQuery(proof: proof,
                                           timestamp: timestamp,
                                           publicKey: publicKey) else { return nil }
            
            return .success(.sign(tx))
        }
    }
}

extension DomainLayer.DTO.MobileKeeper.Error {
    
    var wavesKeeperError: WavesKeeper.Error {
        
        switch self {
        case .message(let message, let code):
            return .message(message, code)
            
        case .reject:
            return .reject
        }
    }
}

fileprivate extension NodeService.Query.Transaction.InvokeScript.Call {
    
    var argsSender: [InvokeScriptTransactionSender.Arg] {
        
        return self.args.map({ (arg) -> InvokeScriptTransactionSender.Arg in
            
            let value = { () -> InvokeScriptTransactionSender.Arg.Value in
                
                switch arg.value {
                case .binary(let value):
                    return .binary(value)
                    
                case .bool(let value):
                    return .bool(value)
                    
                case .integer(let value):
                    return .integer(value)
                    
                case .string(let value):
                    return .string(value)
                }
            }()
            
            return InvokeScriptTransactionSender.Arg(value: value)
        })
    }
    
    var callSender: InvokeScriptTransactionSender.Call {
        return InvokeScriptTransactionSender.Call(function: self.function,
                                                  args: self.argsSender)
    }
}

fileprivate extension TransactionSenderSpecifications {
    
    func nodeQuery(proof: Bytes, timestamp: Date, publicKey: String) -> NodeService.Query.Transaction? {
        
        let proofs = [Base58Encoder.encode(proof)]
        
        switch self {
        case .send(let model):
            
            let transfer = NodeService.Query.Transaction.Transfer.init(recipient: model.recipient,
                                                                       assetId: model.assetId,
                                                                       amount: model.amount,
                                                                       fee: model.fee,
                                                                       attachment: model.attachment,
                                                                       feeAssetId: model.feeAssetID,
                                                                       timestamp: timestamp.millisecondsSince1970,
                                                                       senderPublicKey: publicKey,
                                                                       proofs: proofs,
                                                                       chainId: model.chainId ?? "")
            
            return .transfer(transfer)
            
        case .invokeScript(let model):
            
            var call: NodeService.Query.Transaction.InvokeScript.Call? = nil
                
            if let callLocal = model.call {
                let args = callLocal.args.map({ (arg) -> NodeService.Query.Transaction.InvokeScript.Arg in
                  
                    let value = { () -> NodeService.Query.Transaction.InvokeScript.Arg.Value in
                    
                        switch arg.value {
                        case .binary(let value):
                            return .binary(value)
                            
                        case .bool(let value):
                            return .bool(value)
                            
                        case .integer(let value):
                            return .integer(value)
                            
                        case .string(let value):
                            return .string(value)
                        
                        }
                    }()
                    
                    return .init(value: value)
                })
                
                call = .init(function: callLocal.function, args: args)
            }
            
            let payment = model.payment.map { NodeService.Query.Transaction.InvokeScript.Payment.init(amount: $0.amount, assetId: $0.assetId) }
            
            let invokeScript = NodeService.Query.Transaction.InvokeScript.init(chainId: model.chainId ?? "",
                                                                               fee: model.fee,
                                                                               timestamp: timestamp.millisecondsSince1970,
                                                                               senderPublicKey: publicKey,
                                                                               feeAssetId: model.feeAssetId,
                                                                               proofs: proofs,
                                                                               dApp: model.dApp,
                                                                               call: call,
                                                                               payment: payment)
            
            return .invokeScript(invokeScript)
            
        case .data(let model):
            
            let values = model.data.map { (value) -> NodeService.Query.Transaction.Data.Value in
                
                let kind = { () -> NodeService.Query.Transaction.Data.Value.Kind in
                    switch value.value {
                    case .binary(let value):
                        return .binary(value)
                        
                    case .boolean(let value):
                        return .boolean(value)
                        
                    case .integer(let value):
                        return .integer(value)
                        
                    case .string(let value):
                        return .string(value)
                    }
                }()
                
                return NodeService.Query.Transaction.Data.Value.init(key: value.key, value: kind)
            }
            
            let data = NodeService.Query.Transaction.Data.init(fee: model.fee,
                                                               timestamp: timestamp.millisecondsSince1970,
                                                               senderPublicKey: publicKey,
                                                               proofs: proofs,
                                                               data: values,
                                                               chainId: model.chainId ?? "")
            
            return .data(data)
        default:
            return nil
        }
    }
}

fileprivate extension DomainLayer.DTO.DataTransaction {
    
    var dataTransactionNodeService: NodeService.DTO.DataTransaction {
        
//        <#T##[NodeService.DTO.DataTransaction.Data]#>
        return .init(type: type,
                     id: id,
                     chainId: chainId,
                     sender: sender,
                     senderPublicKey: senderPublicKey,
                     fee: fee,
                     timestamp: timestamp,
                     height: height,
                     version: version,
                     proofs: proofs,
                     data: [])
    }
}

fileprivate extension DomainLayer.DTO.InvokeScriptTransaction {

    var invokeScriptTransactionNodeService: NodeService.DTO.InvokeScriptTransaction {
        
//        <#T##NodeService.DTO.InvokeScriptTransaction.Call?#>
//        <#T##[NodeService.DTO.InvokeScriptTransaction.Payment]#>
        
        return NodeService.DTO.InvokeScriptTransaction(type: self.type,
                                                       id: self.id,
                                                       chainId: self.chainId,
                                                       sender: self.sender,
                                                       senderPublicKey: self.senderPublicKey,
                                                       fee: self.fee,
                                                       timestamp: self.timestamp,
                                                       proofs: self.proofs,
                                                       version: self.version,
                                                       height: self.height,
                                                       feeAssetId: self.feeAssetId,
                                                       dApp: self.dappAddress,
                                                       call: nil,
                                                       payment: [])
    }
    
}

fileprivate extension DomainLayer.DTO.AnyTransaction {
    
    var transactionNodeService: NodeService.DTO.Transaction? {
        
        switch self {
        case .transfer(let model):
            return NodeService.DTO.Transaction.transfer(.init(type: model.type,
                                                              id: model.id,
                                                              sender: model.sender,
                                                              senderPublicKey: model.senderPublicKey,
                                                              fee: model.fee,
                                                              timestamp: model.timestamp,
                                                              version: model.version,
                                                              height: model.height,
                                                              signature: model.signature,
                                                              proofs: model.proofs,
                                                              recipient: model.recipient,
                                                              assetId: model.assetId,
                                                              feeAssetId: model.feeAssetId,
                                                              amount: model.amount,
                                                              attachment: model.attachment))
            
        case .invokeScript(let model):
            return .invokeScript(model.invokeScriptTransactionNodeService)
            
        case .data(let model):
            return .data(model.dataTransactionNodeService)
            
        default:
            return nil
        }
    }
}


fileprivate extension NodeService.Query.Transaction.InvokeScript {
    
    var paymentSender: [InvokeScriptTransactionSender.Payment] {
        return self.payment.map { InvokeScriptTransactionSender.Payment.init(amount: $0.amount, assetId: $0.assetId) }
    }
}

fileprivate extension NodeService.Query.Transaction.Data {
    
    var valueSender: [DataTransactionSender.Value] {
        
        return self.data.map { (data) -> DataTransactionSender.Value in
            
            let kind = { () -> DataTransactionSender.Value.Kind in
                switch data.value {
                case .binary(let value):
                    return .binary(value)
                    
                case .boolean(let value):
                    return .boolean(value)
                    
                case .integer(let value):
                    return .integer(value)
                    
                case .string(let value):
                    return .string(value)
                }
            }()
            
            return DataTransactionSender.Value.init(key: data.key, value: kind)
        }
    }
}


fileprivate extension NodeService.Query.Transaction {
    
    var transactionSenderSpecifications: TransactionSenderSpecifications? {
        
        switch self {
        case .invokeScript(let model):
            
            let sender = InvokeScriptTransactionSender(fee: model.fee,
                                                       feeAssetId: model.feeAssetId,
                                                       dApp: model.dApp,
                                                       call: model.call?.callSender,
                                                       payment: model.paymentSender,
                                                       chainId: model.chainId,
                                                       timestamp: Date.init(milliseconds: model.timestamp))
            
            return .invokeScript(sender)
            
        case .transfer(let model):
            
            let sender = SendTransactionSender.init(recipient: model.recipient,
                                                    assetId: model.assetId,
                                                    amount: model.amount,
                                                    fee: model.fee,
                                                    attachment: model.attachment,
                                                    feeAssetID: model.feeAssetId)
            
            return .send(sender)
            
        case .data(let model):
            
            let sender = DataTransactionSender.init(fee: model.fee,
                                                    data: model.valueSender,
                                                    chainId: model.chainId,
                                                    timestamp: Date.init(milliseconds: model.timestamp))
            
            return .data(sender)
            
        default:
            return nil
        }
    }
}

fileprivate extension DomainLayer.DTO.MobileKeeper.PrepareRequest {
    
    
    func completedRequest(response: DomainLayer.DTO.MobileKeeper.Response,
                          signedWallet: DomainLayer.DTO.SignedWallet) -> DomainLayer.DTO.MobileKeeper.CompletedRequest {
    
        let completedRequest = DomainLayer.DTO.MobileKeeper.CompletedRequest(request: request,
                                                                             timestamp: timestamp,
                                                                             proof: proof,
                                                                             txId: txId,
                                                                             publicKey: signedWallet.publicKey.getPublicKeyStr(),
                                                                             response: response)
        
        return completedRequest
    }
    
    
}


fileprivate extension DomainLayer.DTO.MobileKeeper.Request  {
    
    func transactionSignature(signedWallet: DomainLayer.DTO.SignedWallet,
                              timestamp: Date) -> TransactionSignatureProtocol? {
        
        let senderPublicKey = signedWallet.publicKey.getPublicKeyStr()
        
        switch self.transaction {
        case .data(let tx):
            
            let signature = TransactionSignatureV1.data(.init(fee: tx.fee,
                                                              data: tx.data.map { $0.valueSignatureV1() },
                                                              chainId: tx.chainId ?? "",
                                                              senderPublicKey: senderPublicKey,
                                                              timestamp: timestamp.millisecondsSince1970))
            
            return signature
            
        case .invokeScript(let tx):
            
            let signature = TransactionSignatureV1.invokeScript(.init(senderPublicKey: senderPublicKey,
                                                                      fee: tx.fee,
                                                                      chainId: tx.chainId ?? "",
                                                                      timestamp: timestamp.millisecondsSince1970,
                                                                      feeAssetId: tx.feeAssetId,
                                                                      dApp: tx.dApp,
                                                                      call: tx.call?.callSigantureV1(),
                                                                      payment: tx.payment.map { $0.paymentSigantureV1() }))
            
            return signature
        case .send(let tx):
            
            let signature = TransactionSignatureV2.transfer(.init(senderPublicKey: senderPublicKey,
                                                                  recipient: tx.recipient,
                                                                  assetId: tx.assetId,
                                                                  amount: tx.amount,
                                                                  fee: tx.fee,
                                                                  attachment: tx.attachment,
                                                                  feeAssetID: tx.feeAssetID,
                                                                  chainId: tx.chainId ?? "",
                                                                  timestamp: timestamp.millisecondsSince1970))
            return signature
            
        default:
            return nil
        }
    }
}

fileprivate extension DataTransactionSender.Value  {
    
    func valueSignatureV1() -> TransactionSignatureV1.Structure.Data.Value {
        
        switch self.value {
        case .binary(let value):
            return .init(key: self.key, value: .binary(value))
            
        case .boolean(let value):
            return .init(key: self.key, value: .boolean(value))
            
        case .integer(let value):
            return .init(key: self.key, value: .integer(value))
            
        case .string(let value):
            return .init(key: self.key, value: .string(value))
        }
    }
}

fileprivate extension InvokeScriptTransactionSender.Arg.Value  {

    func argValueSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg.Value {

        switch self {
        case .binary(let value):
            return .binary(value)

        case .bool(let value):
            return .bool(value)

        case .integer(let value):
            return .integer(value)

        case .string(let value):
            return .string(value)
        }
    }
}

fileprivate extension InvokeScriptTransactionSender.Payment {

    func paymentSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Payment {
        return .init(amount: amount, assetId: assetId)
    }
}

fileprivate extension InvokeScriptTransactionSender.Arg {

    func argSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg {

        return TransactionSignatureV1.Structure.InvokeScript.Arg(value: value.argValueSigantureV1())
    }
}

fileprivate extension InvokeScriptTransactionSender.Call  {

    func callSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Call {

        return .init(function: function,
                     args: args.map { $0.argSigantureV1() })
    }

}
