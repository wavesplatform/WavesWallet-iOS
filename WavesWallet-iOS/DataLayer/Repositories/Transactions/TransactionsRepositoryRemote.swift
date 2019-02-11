//
//  TransactionsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CryptoSwift

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

extension TransactionSenderSpecifications {

    var version: Int {
        switch self {
        case .createAlias:
            return 2

        case .lease:
            return 2
            
        case .burn:
            return 2

        case .cancelLease:
            return 2

        case .data:
            return 1

        case .send:
            return 2
        }
    }

    var type: TransactionType {
        switch self {
        case .createAlias:
            return TransactionType.alias

        case .lease:
            return TransactionType.lease
            
        case .burn:
            return TransactionType.burn

        case .cancelLease:
            return TransactionType.leaseCancel

        case .data:
            return TransactionType.data

        case .send:
            return TransactionType.transfer
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    private let transactions: MoyaProvider<Node.Service.Transaction> = .nodeMoyaProvider()
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .nodeMoyaProvider()
    private let transactionRules: MoyaProvider<GitHub.Service.TransactionRules> = .nodeMoyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Observable<[DomainLayer.DTO.AnyTransaction]> in

                guard let owner = self else { return Observable.never() }

                let limit = min(Constants.maxLimit, offset + limit)

                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .list(accountAddress: accountAddress,
                                               limit: limit),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError({ (error) -> Single<Response> in
                        return Single.error(NetworkError.error(by: error))
                    })
                    .map(Node.DTO.TransactionContainers.self)
                    .map { $0.anyTransactions(status: .completed, environment: environment) }
                    .asObservable()
            }
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Observable<[DomainLayer.DTO.LeaseTransaction]> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .leasingProvider
                    .rx
                    .request(.init(kind: .getActive(accountAddress: accountAddress),
                                   environment: environment),
                                   callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError({ (error) -> Single<Response> in
                        return Single.error(NetworkError.error(by: error))
                    })
                    .map([Node.DTO.LeaseTransaction].self)
                    .map { $0.map { tx in
                        return DomainLayer.DTO.LeaseTransaction(transaction: tx, status: .activeNow, environment: environment)
                        }
                    }
                    .asObservable()
            }
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction> {

        return environmentRepository
            .accountEnvironment(accountAddress: wallet.address)
            .flatMap { [weak self] environment -> Observable<DomainLayer.DTO.AnyTransaction> in

                let timestamp = Int64(Date().millisecondsSince1970)
                var signature = specifications.signature(timestamp: timestamp,
                                                         scheme: environment.scheme,
                                                         publicKey: wallet.publicKey.publicKey)

                do {
                    signature = try wallet.sign(input: signature, kind: [.none])
                } catch let e {
                    SweetLogger.error(e)
                    return Observable.error(TransactionsInteractorError.invalid)
                }

                let proofs = [Base58.encode(signature)]

                let broadcastSpecification = specifications.broadcastSpecification(timestamp: timestamp,
                                                                                   environment: environment,
                                                                                   publicKey: wallet.publicKey.getPublicKeyStr(),
                                                                                   proofs: proofs)
                guard let owner = self else { return Observable.never() }
                
                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .broadcast(broadcastSpecification),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError({ (error) -> Single<Response> in
                        return Single.error(NetworkError.error(by: error))
                    })
                    .map(Node.DTO.Transaction.self)
                    .map({ $0.anyTransaction(status: .unconfirmed, environment: environment) })
                    .asObservable()
            }
    }

// MARK - -  Dont support
    func newTransactions(by accountAddress: String,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func transactions(by accountAddress: String,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }


    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules> {
        return transactionRules
            .rx
            .request(.get)
            .map(GitHub.DTO.TransactionFeeRules.self)
            .asObservable()
            .map({ (txRules) -> DomainLayer.DTO.TransactionFeeRules in

                let deffault = txRules.calculate_fee_rules[TransactionFeeDefaultRule]

                let rules = TransactionType
                    .all
                    .reduce(into: [TransactionType: DomainLayer.DTO.TransactionFeeRules.Rule](), { (result, type) in

                    let rule = txRules.calculate_fee_rules["\(type.rawValue)"]

                    let addSmartAssetFee = (rule?.add_smart_asset_fee ?? deffault?.add_smart_asset_fee) ?? false
                    let addSmartAccountFee = (rule?.add_smart_account_fee ?? deffault?.add_smart_account_fee) ?? false
                    let minPriceStep = (rule?.min_price_step ?? deffault?.min_price_step) ?? 0
                    let fee = (rule?.fee ?? deffault?.fee) ?? 0
                    let pricePerTransfer = (rule?.price_per_transfer ?? deffault?.price_per_transfer) ?? 0
                    let pricePerKb = (rule?.price_per_kb ?? deffault?.price_per_kb) ?? 0

                    let newRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: addSmartAssetFee,
                                                                           addSmartAccountFee: addSmartAccountFee,
                                                                           minPriceStep: minPriceStep,
                                                                           fee: fee,
                                                                           pricePerTransfer: pricePerTransfer,
                                                                           pricePerKb: pricePerKb)

                    result[type] = newRule
                })


                let newDefaultRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: deffault?.add_smart_asset_fee ?? false,
                                                                              addSmartAccountFee: deffault?.add_smart_account_fee ?? false,
                                                                              minPriceStep: deffault?.min_price_step ?? 0,
                                                                              fee: deffault?.fee ?? 0,
                                                                              pricePerTransfer: deffault?.price_per_transfer ?? 0,
                                                                              pricePerKb: deffault?.price_per_kb ?? 0)


                let newRules = DomainLayer.DTO.TransactionFeeRules(smartAssetExtraFee: txRules.smart_asset_extra_fee,
                                                                   smartAccountExtraFee: txRules.smart_account_extra_fee,
                                                                   defaultRule: newDefaultRule,
                                                                   rules: rules)

                return newRules
            })
    }
}



fileprivate extension TransactionSenderSpecifications {

    func broadcastSpecification(timestamp: Int64,
                                environment: Environment,
                                publicKey: String,
                                proofs: [String]) -> Node.Service.Transaction.BroadcastSpecification {

        switch self {
            
        case .burn(let model):
            
            return .burn(Node.Service.Transaction.Burn(version: self.version,
                                                        type: self.type.rawValue,
                                                        scheme: environment.scheme,
                                                        fee: model.fee,
                                                        assetId: model.assetID,
                                                        quantity: model.quantity,
                                                        timestamp: timestamp,
                                                        senderPublicKey: publicKey,
                                                        proofs: proofs))
            
        case .createAlias(let model):

            return .createAlias(Node.Service.Transaction.Alias(version: self.version,
                                                               name: model.alias,
                                                               fee: model.fee,
                                                               timestamp: timestamp,
                                                               type: self.type.rawValue,
                                                               senderPublicKey: publicKey,
                                                               proofs: proofs))
        case .lease(let model):

            var recipient = ""
            if model.recipient.count <= GlobalConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            return .startLease(Node.Service.Transaction.Lease(version: self.version,
                                                              scheme: environment.scheme,
                                                              fee: model.fee,
                                                              recipient: recipient,
                                                              amount: model.amount,
                                                              timestamp: timestamp,
                                                              type: self.type.rawValue,
                                                              senderPublicKey: publicKey,
                                                              proofs: proofs))
        case .cancelLease(let model):

            return .cancelLease(Node.Service.Transaction.LeaseCancel(version: self.version,
                                                                     scheme: environment.scheme,
                                                                     fee: model.fee,
                                                                     leaseId: model.leaseId,
                                                                     timestamp: timestamp,
                                                                     type: self.type.rawValue,
                                                                     senderPublicKey: publicKey,
                                                                     proofs: proofs))

        case .data(let model):

            return .data(Node.Service.Transaction.Data.init(type: self.type.rawValue,
                                                            version: self.version,
                                                            fee: model.fee,
                                                            timestamp: timestamp,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs,
                                                            data: model.dataForNode))
            
        case .send(let model):
            
            var recipient = ""
            if model.recipient.count <= GlobalConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            
            return .send(Node.Service.Transaction.Send(type: self.type.rawValue,
                                                       version: self.version,
                                                       recipient: recipient,
                                                       assetId: model.assetId,
                                                       amount: model.amount,
                                                       fee: model.fee,
                                                       attachment: Base58.encode(Array(model.attachment.utf8)),
                                                       feeAssetId: model.getFeeAssetID,
                                                       timestamp: timestamp,
                                                       senderPublicKey: publicKey,
                                                       proofs: proofs))
        }

    }

    func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {

        switch self {

        case .data(let model):
            //TODO: check size
            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += publicKey
            signature += model.bytesForSignature
            signature += toByteArray(timestamp)
            signature += toByteArray(model.fee)
            return signature

        case .burn(let model):

            let assetId: [UInt8] = Base58.decode(model.assetID)

            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += scheme.utf8
            signature += publicKey
            signature += assetId
            signature += toByteArray(model.quantity)
            signature += toByteArray(model.fee)
            signature += toByteArray(timestamp)
            return signature

        case .cancelLease(let model):

            let leaseId: [UInt8] = Base58.decode(model.leaseId)

            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += scheme.utf8
            signature += publicKey
            signature += toByteArray(model.fee)
            signature += toByteArray(timestamp)
            signature += leaseId
            return signature

        case .createAlias(let model):

            var alias: [UInt8] = toByteArray(Int8(self.version))
            alias += scheme.utf8
            alias += model.alias.arrayWithSize()

            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += publicKey

            signature += alias.arrayWithSize()
            signature += toByteArray(model.fee)
            signature += toByteArray(timestamp)
            return signature

        case .lease(let model):

            var recipient: [UInt8] = []
            if model.recipient.count <= GlobalConstants.aliasNameMaxLimitSymbols {
                recipient += toByteArray(Int8(self.version))
                recipient += scheme.utf8
                recipient += model.recipient.arrayWithSize()
            } else {
                recipient += Base58.decode(model.recipient)
            }

            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += [0]
            signature += publicKey

            signature += recipient
            signature += toByteArray(model.amount)
            signature += toByteArray(model.fee)
            signature += toByteArray(timestamp)
            return signature
            
        case .send(let model):
           
            var recipient: [UInt8] = []
            if model.recipient.count <= GlobalConstants.aliasNameMaxLimitSymbols {
                recipient += toByteArray(Int8(self.version))
                recipient += scheme.utf8
                recipient += model.recipient.arrayWithSize()
            } else {
                recipient += Base58.decode(model.recipient)
            }
            
            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += publicKey
            signature += model.assetId.isEmpty ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(model.assetId))
            signature += model.getFeeAssetID.isEmpty ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(model.getFeeAssetID))
            signature += toByteArray(timestamp)
            signature += toByteArray(model.amount)
            signature += toByteArray(model.fee)
            signature += recipient
            signature += model.attachment.arrayWithSize()
            
            return signature
        }
    }
}

private extension SendTransactionSender {
   
    var getFeeAssetID: String {
        return feeAssetID == GlobalConstants.wavesAssetId ? "" : feeAssetID
    }
}

private extension DataTransactionSender {

    var bytesForSignature: [UInt8] {

        var signature: [UInt8] = []
        signature += toByteArray(Int16(self.data.count))

        for value in self.data {
            signature += value.key.arrayWithSize()

            switch value.value {
            case .binary(let data):
                signature += toByteArray(Int8(2))
                signature += data.arrayWithSize()

            case .integer(let number):
                signature += toByteArray(Int8(0))
                signature += toByteArray(number)

            case .boolean(let flag):
                signature += toByteArray(Int8(1))
                signature += toByteArray(flag)

            case .string(let str):
                signature += toByteArray(Int8(3))
                signature += str.arrayWithSize()
            }
        }
        return signature
    }

    var dataForNode: [Node.Service.Transaction.Data.Value] {
        return self.data.map { (value) -> Node.Service.Transaction.Data.Value in

            var kind: Node.Service.Transaction.Data.Value.Kind!

            switch value.value {
            case .binary(let data):
                kind = .binary(data.toBase64() ?? "")

            case .integer(let number):
                kind = .integer(number)

            case .boolean(let flag):
                kind = .boolean(flag)

            case .string(let str):
                kind = .string(str)
            }

            return Node.Service.Transaction.Data.Value.init(key: value.key, value: kind)
        }
    }
}
