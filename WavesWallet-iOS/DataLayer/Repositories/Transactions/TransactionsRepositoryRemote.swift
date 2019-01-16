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
        
        case .send:
            return TransactionType.transfer
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    private let transactions: MoyaProvider<Node.Service.Transaction> = .nodeMoyaProvider()
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .nodeMoyaProvider()

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
                    error(e)
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
                                                       timestamp: timestamp,
                                                       senderPublicKey: publicKey,
                                                       proofs: proofs))
        }

    }

    func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {

        switch self {
        
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
            signature +=  toByteArray(Int8(self.version))
            signature += publicKey
            signature += model.assetId.isEmpty ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(model.assetId))
            signature += [UInt8(0)]
            signature += toByteArray(timestamp)
            signature += toByteArray(model.amount)
            signature += toByteArray(model.fee)
            signature += recipient
            signature += model.attachment.arrayWithSize()
            
            return signature
        }
    }
}


