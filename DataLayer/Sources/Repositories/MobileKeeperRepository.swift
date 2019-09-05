//
//  MobileKeeperRepository.swift
//  DataLayer
//
//  Created by rprokofev on 01.09.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Extensions
import WavesSDK
import WavesSDKExtensions
import WavesSDKCrypto

//Rename to UseCase

public class MobileKeeperRepository: MobileKeeperRepositoryProtocol {
    
    private var repositoriesFactory: RepositoriesFactoryProtocol
    
    init(repositoriesFactory: RepositoriesFactoryProtocol) {
        self.repositoriesFactory = repositoriesFactory
    }
    
    public func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                               signedWallet: DomainLayer.DTO.SignedWallet,
                               timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest> {
        
        
        guard let signature = request.transactionSignature(signedWallet: signedWallet,
                                                           timestamp: timestamp) else {
            return Observable.error(MobileKeeperUseCaseError.transactionDontSupport)
        }
        
        //TODO: Error
        let proof = (try? signedWallet.sign(input: signature.bytesStructure, kind: [.none])) ?? []
        
        let transaction = request.transaction.transactionNormalization(proof: proof, timestamp: timestamp, publicKey: signedWallet.publicKey.getPublicKeyStr()) ?? request.transaction
        
        let requestNorm = DomainLayer
            .DTO
            .MobileKeeper.Request.init(dApp: request.dApp, action: request.action, transaction: transaction, id: request.id)
        
        let prepareRequest = DomainLayer
            .DTO
            .MobileKeeper
            .PrepareRequest.init(request: requestNorm,
                                 timestamp: timestamp,
                                 proof: proof,
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
    
    
    public func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) -> Observable<Bool> {
        
        return returnResponse(for: completedRequest.request.dApp,
                              completedRequest: completedRequest)
    }
    
    public func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request) -> Observable<Bool> {
        
        return returnError(for: request.dApp,
                           requestId: request.id,
                           error: .reject)
    }
    
    public func errorRequest(_ request: DomainLayer.DTO.MobileKeeper.Request, error: DomainLayer.DTO.MobileKeeper.Error) -> Observable<Bool> {
        
        return returnError(for: request.dApp,
                           requestId: request.id,
                           error: error)
    }
    
    public func decodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?> {
        
        var requestOptional: WavesKeeper.Request? = nil
        
        do {
            requestOptional = try self.decodableKeeperRequest(url, sourceApplication: sourceApplication)
        } catch let error as MobileKeeperUseCaseError {
            return Observable.error(error)
        } catch _ {
            return Observable.just(nil)
        }
        
        guard let request = requestOptional else { return Observable.just(nil) }
        guard let transactionSenderSpecifications = request.transaction.transactionSenderSpecifications else {
            return Observable.error(MobileKeeperUseCaseError.transactionDontSupport)
        }
        
        let mobileKeeperRequest = DomainLayer
            .DTO
            .MobileKeeper
            .Request
            .init(dApp: .init(name: request.dApp.name,
                              iconUrl: request.dApp.iconUrl,
                              scheme: request.dApp.schemeUrl),
                  action: (request.action == .send ? .send : .sign),
                  transaction: transactionSenderSpecifications,
                  id: request.id)
        
        return Observable.just(mobileKeeperRequest)
    }
    
    
    private func returnError(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                             requestId: String,
                             error: DomainLayer.DTO.MobileKeeper.Error) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            let wavesKeeperReponse: WavesKeeper.Response = .init(requestId: requestId,
                                                                 kind: .error(error.wavesKeeperError))
            
            let wavesKeeperApplication = dApp.wavesKeeperApplication
            
            guard let url = wavesKeeperReponse.url(app: wavesKeeperApplication) else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            UIApplication.shared.open(url, options: .init(), completionHandler: { (flag) in
                if flag == false {
                    observer.onError(MobileKeeperUseCaseError.dAppDontOpen)
                } else {
                    observer.onNext(flag)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        })
    }
    
    private func returnResponse(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                                completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            let wavesKeeperApplication = dApp.wavesKeeperApplication
            guard let wavesKeeperResponse = completedRequest.wavesKeeperResponse else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            guard let url = wavesKeeperResponse.url(app: wavesKeeperApplication) else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            UIApplication.shared.open(url, options: .init(), completionHandler: { (flag) in
                
                if flag == false {
                    observer.onError(MobileKeeperUseCaseError.dAppDontOpen)
                } else {
                    observer.onNext(flag)
                }
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
    }
    
    private func decodableKeeperRequest(_ url: URL, sourceApplication: String) throws -> WavesKeeper.Request? {
        return try url.request()
    }
}
    

fileprivate extension DomainLayer.DTO.MobileKeeper.Application {
    
    var wavesKeeperApplication: WavesKeeper.Application {
        return .init(name: name, iconUrl: iconUrl, schemeUrl: scheme)
    }
}

extension DomainLayer.DTO.MobileKeeper.CompletedRequest {
 
    var wavesKeeperResponse: WavesKeeper.Response? {
        
        guard let wavesKeeperResponseKind = self.wavesKeeperResponseKind else { return nil }
        
        return WavesKeeper.Response.init(requestId: request.id,
                                         kind: wavesKeeperResponseKind)
    }
    
    var wavesKeeperResponseKind: WavesKeeper.Response.Kind? {
        
        switch self.response.kind {
            
        case .error(let error):
            return .error(error.wavesKeeperError)
            
        case .success(let result):
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
}

extension DomainLayer.DTO.MobileKeeper.Error {
    
    var wavesKeeperError: WavesKeeper.Error {
        
        switch self {
        case .message(let message, let code):
            return .message(.init(message: message, code: code))
            
        case .reject:
            return .reject
            
        case .invalidRequest:
            return .invalidRequest
            
        case .transactionDontSupport:
            return .transactionDontSupport
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
    
    func transactionNormalization(proof: Bytes, timestamp: Date, publicKey: String) -> TransactionSenderSpecifications? {
        
        switch self {
        case .send(let sender):
            return .send(SendTransactionSender.init(recipient: sender.recipient,
                                                    assetId: sender.assetId,
                                                    amount: sender.amount,
                                                    fee: sender.fee,
                                                    attachment: sender.attachment,
                                                    feeAssetID: sender.feeAssetID,
                                                    chainId: sender.chainId,
                                                    timestamp: timestamp))
        case .invokeScript(let model):
            
            return .invokeScript(.init(fee: model.fee,
                                       feeAssetId: model.feeAssetId,
                                       dApp: model.dApp,
                                       call: model.call,
                                       payment: model.payment,
                                       chainId: model.chainId,
                                       timestamp: model.timestamp))
            
        case .data(let model):
            return .data(.init(fee: model.fee,
                               data: model.data,
                               chainId: model.chainId,
                               timestamp: model.timestamp))
            
        default:
            return nil
        }
    }
    
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
        //TODO:
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
        
        //TODO:
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
                                                    feeAssetID: model.feeAssetId,
                                                    chainId: model.chainId,
                                                    timestamp: Date.init(milliseconds: model.timestamp))
            
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
    
    
    func completedRequest(response: DomainLayer.DTO.MobileKeeper.Response.Kind,
                          signedWallet: DomainLayer.DTO.SignedWallet) -> DomainLayer.DTO.MobileKeeper.CompletedRequest {
    

        let completedRequest = DomainLayer.DTO.MobileKeeper.CompletedRequest(request: request,
                                                                             timestamp: timestamp,
                                                                             proof: proof,
                                                                             txId: txId,
                                                                             publicKey: signedWallet.publicKey.getPublicKeyStr(),
                                                                             response: .init(requestId: request.id,
                                                                                             kind: response))
        
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

private extension URL {
    
    func request() throws -> WavesKeeper.Request? {
        
        guard let component = URLComponents.init(url: self, resolvingAgainstBaseURL: true) else { return nil }
        guard component.path == "keeper/v1/request" else { throw MobileKeeperUseCaseError.dataIncorrect }
        guard let item = (component.queryItems?.first { $0.name == "data" }) else { throw MobileKeeperUseCaseError.dataIncorrect }
        guard let value = item.value else { throw MobileKeeperUseCaseError.dataIncorrect }
        
        guard let request: WavesKeeper.Request = value.decodableBase64ToObject() else {
            throw MobileKeeperUseCaseError.dataIncorrect
        }
        
        return request
    }
}

private extension WavesKeeper.Response {
    
    func url(app: WavesKeeper.Application) -> URL? {
        
        guard let base64 = self.encodableToBase64 else { return nil }
        
        var component = URLComponents(string: "")
        
        component?.scheme = app.schemeUrl.components(separatedBy: CharacterSet.urlFragmentAllowed.inverted).joined().lowercased()
        component?.path = "keeper/v1/response"
        component?.queryItems = [URLQueryItem(name: "data", value: base64)]
        
        return try? component?.asURL()
    }
}

