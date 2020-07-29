//
//  MobileKeeperRepository.swift
//  DataLayer
//
//  Created by rprokofev on 01.09.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

// Rename to UseCase

public class MobileKeeperRepository: MobileKeeperRepositoryProtocol {
    private var repositoriesFactory: RepositoriesFactoryProtocol

    init(repositoriesFactory: RepositoriesFactoryProtocol) {
        self.repositoriesFactory = repositoriesFactory
    }

    public func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                               signedWallet: SignedWallet,
                               timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest> {
        guard let signature = request.transactionSignature(signedWallet: signedWallet,
                                                           timestamp: timestamp) else {
            return Observable.error(MobileKeeperUseCaseError.transactionDontSupport)
        }

        // TODO: Error
        let proof = (try? signedWallet.sign(input: signature.bytesStructure, kind: [.none])) ?? []

        let transaction = request.transaction
            .transactionNormalization(proof: proof,
                                      timestamp: timestamp,
                                      publicKey: signedWallet.publicKey.getPublicKeyStr()) ?? request.transaction

        let requestNorm = DomainLayer
            .DTO
            .MobileKeeper.Request(dApp: request.dApp, action: request.action, transaction: transaction, id: request.id)

        let prepareRequest = DomainLayer
            .DTO
            .MobileKeeper
            .PrepareRequest(request: requestNorm,
                            timestamp: timestamp,
                            proof: proof,
                            txId: signature.id,
                            signedWallet: signedWallet)

        return Observable.just(prepareRequest)
    }

    public func completeRequest(serverEnvironment: ServerEnvironment,
                                prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest)
        -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> {
        let action = prepareRequest.request.action

        switch action {
        case .send:

            return repositoriesFactory
                .transactionsRepository
                .send(serverEnvironment: serverEnvironment,
                      specifications: prepareRequest.request.transaction,
                      wallet: prepareRequest.signedWallet)
                .flatMap { tx -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in

                    let completedRequest = prepareRequest.completedRequest(response: .success(.send(tx)),
                                                                           signedWallet: prepareRequest.signedWallet)
                    return Observable.just(completedRequest)
                }
                .catchError { error -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in

                    if let networkError = error as? NetworkError {
                        let title = { () -> String in
                            switch networkError {
                            case let .message(message):
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
                }

        case .sign:

            let completedRequest = prepareRequest.completedRequest(response: .success(.sign(prepareRequest.request.transaction)),
                                                                   signedWallet: prepareRequest.signedWallet)
            return Observable.just(completedRequest)
        }
    }

    public func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) -> Observable<Bool> {
        returnResponse(for: completedRequest.request.dApp, completedRequest: completedRequest)
    }

    public func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request) -> Observable<Bool> {
        returnError(for: request.dApp, requestId: request.id, error: .reject)
    }

    public func errorRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                             error: DomainLayer.DTO.MobileKeeper.Error) -> Observable<Bool> {
        returnError(for: request.dApp,
                    requestId: request.id,
                    error: error)
    }

    public func decodableRequest(_ url: URL) -> Observable<DomainLayer.DTO.MobileKeeper.Request?> {
        var requestOptional: WavesKeeper.Request?

        do {
            requestOptional = try decodableKeeperRequest(url)
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
            .Request(dApp: .init(name: request.dApp.name,
                                 iconUrl: request.dApp.iconUrl,
                                 scheme: request.dApp.schemeUrl),
                     action: request.action == .send ? .send : .sign,
                     transaction: transactionSenderSpecifications,
                     id: request.id)

        return Observable.just(mobileKeeperRequest)
    }

    private func returnError(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                             requestId: String,
                             error: DomainLayer.DTO.MobileKeeper.Error) -> Observable<Bool> {
        Observable<Bool>.create { (observer) -> Disposable in

            let wavesKeeperReponse: WavesKeeper.Response = .init(requestId: requestId,
                                                                 kind: .error(error.wavesKeeperError))

            let wavesKeeperApplication = dApp.wavesKeeperApplication

            guard let url = wavesKeeperReponse.url(app: wavesKeeperApplication) else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }

            UIApplication.shared.open(url, options: .init(), completionHandler: { flag in
                if flag == false {
                    observer.onError(MobileKeeperUseCaseError.dAppDontOpen)
                } else {
                    observer.onNext(flag)
                    observer.onCompleted()
                }
            })

            return Disposables.create()
        }
    }

    private func returnResponse(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                                completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) -> Observable<Bool> {
        return Observable<Bool>.create { (observer) -> Disposable in

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

            UIApplication.shared.open(url, options: .init(), completionHandler: { flag in

                if flag == false {
                    observer.onError(MobileKeeperUseCaseError.dAppDontOpen)
                } else {
                    observer.onNext(flag)
                }
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    private func decodableKeeperRequest(_ url: URL) throws -> WavesKeeper.Request? {
        return try url.request()
    }
}

private extension DomainLayer.DTO.MobileKeeper.Application {
    var wavesKeeperApplication: WavesKeeper.Application {
        return .init(name: name, iconUrl: iconUrl, schemeUrl: scheme)
    }
}

extension DomainLayer.DTO.MobileKeeper.CompletedRequest {
    var wavesKeeperResponse: WavesKeeper.Response? {
        guard let wavesKeeperResponseKind = self.wavesKeeperResponseKind else { return nil }

        return WavesKeeper.Response(requestId: request.id,
                                    kind: wavesKeeperResponseKind)
    }

    var wavesKeeperResponseKind: WavesKeeper.Response.Kind? {
        switch response.kind {
        case let .error(error):
            return .error(error.wavesKeeperError)

        case let .success(result):
            switch result {
            case let .send(model):
                guard let tx = model.transactionNodeService else { return nil }

                return .success(.send(tx))

            case let .sign(model):

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
        case let .message(message, code):
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

private extension NodeService.Query.Transaction.InvokeScript.Call {
    var argsSender: [InvokeScriptTransactionSender.Arg] {
        return args.map { (arg) -> InvokeScriptTransactionSender.Arg in

            let value = { () -> InvokeScriptTransactionSender.Arg.Value in

                switch arg.value {
                case let .binary(value):
                    return .binary(value)

                case let .bool(value):
                    return .bool(value)

                case let .integer(value):
                    return .integer(value)

                case let .string(value):
                    return .string(value)
                }
            }()

            return InvokeScriptTransactionSender.Arg(value: value)
        }
    }

    var callSender: InvokeScriptTransactionSender.Call {
        return InvokeScriptTransactionSender.Call(function: function,
                                                  args: argsSender)
    }
}

private extension TransactionSenderSpecifications {
    func transactionNormalization(proof _: Bytes, timestamp: Date, publicKey _: String) -> TransactionSenderSpecifications? {
        switch self {
        case let .send(sender):
            return .send(SendTransactionSender(recipient: sender.recipient,
                                               assetId: sender.assetId,
                                               amount: sender.amount,
                                               fee: sender.fee,
                                               attachment: sender.attachment,
                                               feeAssetID: sender.feeAssetID,
                                               chainId: sender.chainId,
                                               timestamp: timestamp))
        case let .invokeScript(model):

            return .invokeScript(.init(fee: model.fee,
                                       feeAssetId: model.feeAssetId,
                                       dApp: model.dApp,
                                       call: model.call,
                                       payment: model.payment,
                                       chainId: model.chainId,
                                       timestamp: timestamp))

        case let .data(model):
            return .data(.init(fee: model.fee,
                               data: model.data,
                               chainId: model.chainId,
                               timestamp: timestamp))

        default:
            return nil
        }
    }

    func nodeQuery(proof: Bytes, timestamp: Date, publicKey: String) -> NodeService.Query.Transaction? {
        let proofs = [Base58Encoder.encode(proof)]

        switch self {
        case let .send(model):

            let transfer = NodeService.Query.Transaction.Transfer(recipient: model.recipient,
                                                                  assetId: model.assetId,
                                                                  amount: model.amount,
                                                                  fee: model.fee,
                                                                  attachment: model.attachment,
                                                                  feeAssetId: model.feeAssetID,
                                                                  timestamp: timestamp.millisecondsSince1970,
                                                                  senderPublicKey: publicKey,
                                                                  proofs: proofs,
                                                                  chainId: model.chainId ?? 0)

            return .transfer(transfer)

        case let .invokeScript(model):

            var call: NodeService.Query.Transaction.InvokeScript.Call?

            if let callLocal = model.call {
                let args = callLocal.args.map { (arg) -> NodeService.Query.Transaction.InvokeScript.Arg in

                    let value = { () -> NodeService.Query.Transaction.InvokeScript.Arg.Value in

                        switch arg.value {
                        case let .binary(value):
                            return .binary(value)

                        case let .bool(value):
                            return .bool(value)

                        case let .integer(value):
                            return .integer(value)

                        case let .string(value):
                            return .string(value)
                        }
                    }()

                    return .init(value: value)
                }

                call = .init(function: callLocal.function, args: args)
            }

            let payment = model.payment
                .map { NodeService.Query.Transaction.InvokeScript.Payment(amount: $0.amount, assetId: $0.assetId) }

            let invokeScript = NodeService.Query.Transaction.InvokeScript(chainId: model.chainId ?? 0,
                                                                          fee: model.fee,
                                                                          timestamp: timestamp.millisecondsSince1970,
                                                                          senderPublicKey: publicKey,
                                                                          feeAssetId: model.feeAssetId,
                                                                          proofs: proofs,
                                                                          dApp: model.dApp,
                                                                          call: call,
                                                                          payment: payment)

            return .invokeScript(invokeScript)

        case let .data(model):

            let values = model.data.map { (value) -> NodeService.Query.Transaction.Data.Value in

                let kind: NodeService.Query.Transaction.Data.Value.Kind?

                if let valueKind = value.value {
                    switch valueKind {
                    case let .binary(value):
                        kind = .binary(value)

                    case let .boolean(value): kind = .boolean(value)

                    case let .integer(value):
                        kind = .integer(value)

                    case let .string(value):
                        kind = .string(value)
                    }
                } else {
                    kind = nil
                }

                return NodeService.Query.Transaction.Data.Value(key: value.key, value: kind)
            }

            let data = NodeService.Query.Transaction.Data(fee: model.fee,
                                                          timestamp: timestamp.millisecondsSince1970,
                                                          senderPublicKey: publicKey,
                                                          proofs: proofs,
                                                          data: values,
                                                          chainId: model.chainId ?? 0)

            return .data(data)
        default:
            return nil
        }
    }
}

private extension DataTransaction {
    var dataTransactionNodeService: NodeService.DTO.DataTransaction {
        let data = self.data.map { (element) -> NodeService.DTO.DataTransaction.Data in

            let dataValue: NodeService.DTO.DataTransaction.Data.Value?

            if let element = element.value {
                switch element {
                case let .binary(value):
                    dataValue = .binary(value)

                case let .bool(value):
                    dataValue = .bool(value)

                case let .integer(value):
                    dataValue = .integer(value)

                case let .string(value):
                    dataValue = .string(value)
                }

            } else {
                dataValue = nil
            }

            return NodeService.DTO.DataTransaction.Data(key: element.key, type: element.type, value: dataValue)
        }

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
                     data: data,
                     applicationStatus: nil)
    }
}

private extension InvokeScriptTransaction {
    var invokeScriptTransactionNodeService: NodeService.DTO.InvokeScriptTransaction {
        var call: NodeService.DTO.InvokeScriptTransaction.Call?

        if let localCall = self.call {
            let args = localCall.args.map { (arg) -> NodeService.DTO.InvokeScriptTransaction.Call.Args in
                let value = { () -> NodeService.DTO.InvokeScriptTransaction.Call.Args.Value in

                    switch arg.value {
                    case let .binary(value):
                        return .binary(value)

                    case let .bool(value):
                        return .bool(value)

                    case let .integer(value):
                        return .integer(value)

                    case let .string(value):
                        return .string(value)
                    }
                }()

                return .init(type: arg.type, value: value)
            }

            call = .init(function: localCall.function, args: args)
        }
        
        let payments: [NodeService.DTO.InvokeScriptTransaction.Payment] = self.payments?
            .map { payment -> NodeService.DTO.InvokeScriptTransaction.Payment in

                NodeService.DTO.InvokeScriptTransaction.Payment(amount: payment.amount, assetId: payment.assetId)
            } ?? []

        return NodeService.DTO.InvokeScriptTransaction(type: type,
                                                       id: id,
                                                       chainId: chainId,
                                                       sender: sender,
                                                       senderPublicKey: senderPublicKey,
                                                       fee: fee,
                                                       timestamp: timestamp,
                                                       proofs: proofs,
                                                       version: version,
                                                       height: height,
                                                       feeAssetId: feeAssetId,
                                                       dApp: dappAddress,
                                                       call: call,
                                                       payment: payments,
                                                       applicationStatus: nil)
    }
}

private extension AnyTransaction {
    // TODO: Incorect chainID
    var transactionNodeService: NodeService.DTO.Transaction? {
        switch self {
        case let .transfer(model):
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
                                                              attachment: model.attachment,
                                                              applicationStatus: nil))

        case let .invokeScript(model):
            return .invokeScript(model.invokeScriptTransactionNodeService)

        case let .data(model):
            return .data(model.dataTransactionNodeService)

        default:
            return nil
        }
    }
}

private extension NodeService.Query.Transaction.InvokeScript {
    var paymentSender: [InvokeScriptTransactionSender.Payment] {
        return payment.map { InvokeScriptTransactionSender.Payment(amount: $0.amount, assetId: $0.assetId) }
    }
}

private extension NodeService.Query.Transaction.Data {
    var valueSender: [DataTransactionSender.Value] {
        return data.map { (data) -> DataTransactionSender.Value in

            let kind: DataTransactionSender.Value.Kind?

            if let value = data.value {
                switch value {
                case let .binary(value):
                    kind = .binary(value)

                case let .boolean(value):
                    kind = .boolean(value)

                case let .integer(value):
                    kind = .integer(value)

                case let .string(value):
                    kind = .string(value)
                }
            } else {
                kind = nil
            }

            return DataTransactionSender.Value(key: data.key, value: kind)
        }
    }
}

private extension NodeService.Query.Transaction {
    var transactionSenderSpecifications: TransactionSenderSpecifications? {
        switch self {
        case let .invokeScript(model):

            let sender = InvokeScriptTransactionSender(fee: model.fee,
                                                       feeAssetId: model.feeAssetId,
                                                       dApp: model.dApp,
                                                       call: model.call?.callSender,
                                                       payment: model.paymentSender,
                                                       chainId: model.chainId,
                                                       timestamp: Date(milliseconds: model.timestamp))

            return .invokeScript(sender)

        case let .transfer(model):

            let sender = SendTransactionSender(recipient: model.recipient,
                                               assetId: model.assetId,
                                               amount: model.amount,
                                               fee: model.fee,
                                               attachment: model.attachment,
                                               feeAssetID: model.feeAssetId,
                                               chainId: model.chainId,
                                               timestamp: Date(milliseconds: model.timestamp))

            return .send(sender)

        case let .data(model):

            let sender = DataTransactionSender(fee: model.fee,
                                               data: model.valueSender,
                                               chainId: model.chainId,
                                               timestamp: Date(milliseconds: model.timestamp))

            return .data(sender)

        default:
            return nil
        }
    }
}

private extension DomainLayer.DTO.MobileKeeper.PrepareRequest {
    func completedRequest(response: DomainLayer.DTO.MobileKeeper.Response.Kind,
                          signedWallet: SignedWallet) -> DomainLayer.DTO.MobileKeeper.CompletedRequest {
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

private extension DomainLayer.DTO.MobileKeeper.Request {
    func transactionSignature(signedWallet: SignedWallet,
                              timestamp: Date) -> TransactionSignatureProtocol? {
        let senderPublicKey = signedWallet.publicKey.getPublicKeyStr()

        switch transaction {
        case let .data(tx):

            let signature = TransactionSignatureV1.data(.init(fee: tx.fee,
                                                              data: tx.data.map { $0.valueSignatureV1() },
                                                              chainId: tx.chainId ?? 0,
                                                              senderPublicKey: senderPublicKey,
                                                              timestamp: timestamp.millisecondsSince1970))

            return signature

        case let .invokeScript(tx):

            let signature = TransactionSignatureV1.invokeScript(.init(senderPublicKey: senderPublicKey,
                                                                      fee: tx.fee,
                                                                      chainId: tx.chainId ?? 0,
                                                                      timestamp: timestamp.millisecondsSince1970,
                                                                      feeAssetId: tx.feeAssetId,
                                                                      dApp: tx.dApp,
                                                                      call: tx.call?.callSigantureV1(),
                                                                      payment: tx.payment.map { $0.paymentSigantureV1() }))

            return signature
        case let .send(tx):

            let signature = TransactionSignatureV2.transfer(.init(senderPublicKey: senderPublicKey,
                                                                  recipient: tx.recipient,
                                                                  assetId: tx.assetId,
                                                                  amount: tx.amount,
                                                                  fee: tx.fee,
                                                                  attachment: tx.attachment,
                                                                  feeAssetID: tx.feeAssetID,
                                                                  chainId: tx.chainId ?? 0,
                                                                  timestamp: timestamp.millisecondsSince1970))
            return signature

        default:
            return nil
        }
    }
}

private extension DataTransactionSender.Value {
    func valueSignatureV1() -> TransactionSignatureV1.Structure.Data.Value {
        guard let valueKind = value else { return .init(key: key, value: nil) }

        switch valueKind {
        case let .binary(value):
            return .init(key: key, value: .binary(value))

        case let .boolean(value):
            return .init(key: key, value: .boolean(value))

        case let .integer(value):
            return .init(key: key, value: .integer(value))

        case let .string(value):
            return .init(key: key, value: .string(value))
        }
    }
}

private extension InvokeScriptTransactionSender.Arg.Value {
    func argValueSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg.Value {
        switch self {
        case let .binary(value):
            return .binary(value)

        case let .bool(value):
            return .bool(value)

        case let .integer(value):
            return .integer(value)

        case let .string(value):
            return .string(value)
        }
    }
}

private extension InvokeScriptTransactionSender.Payment {
    func paymentSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Payment {
        return .init(amount: amount, assetId: assetId)
    }
}

private extension InvokeScriptTransactionSender.Arg {
    func argSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg {
        return TransactionSignatureV1.Structure.InvokeScript.Arg(value: value.argValueSigantureV1())
    }
}

private extension InvokeScriptTransactionSender.Call {
    func callSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Call {
        return .init(function: function,
                     args: args.map { $0.argSigantureV1() })
    }
}

private extension URL {
    func request() throws -> WavesKeeper.Request? {
        guard let component = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
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
        guard let base64 = encodableToBase64 else { return nil }

        var component = URLComponents(string: "")

        component?.scheme = app.schemeUrl.components(separatedBy: CharacterSet.urlFragmentAllowed.inverted).joined().lowercased()
        component?.path = "keeper/v1/response"
        component?.queryItems = [URLQueryItem(name: "data", value: base64)]

        return try? component?.asURL()
    }
}
