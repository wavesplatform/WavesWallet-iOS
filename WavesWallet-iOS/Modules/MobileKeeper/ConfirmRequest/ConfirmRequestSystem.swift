//
//  ConfirmRequestSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa
import Extensions
import WavesSDKExtensions
import WavesSDK
import WavesSDKCrypto

private typealias Types = ConfirmRequest

final class ConfirmRequestSystem: System<ConfirmRequest.State, ConfirmRequest.Event> {
    
    private lazy var assetsUseCase: AssetsUseCaseProtocol = UseCasesFactory.instance.assets
    
    private let input: ConfirmRequest.DTO.Input
    
    init(input: ConfirmRequest.DTO.Input) {
        self.input = input
    }
    
    override func initialState() -> State! {
        return ConfirmRequest.State(ui: uiState(),
                                    core: coreState(input: self.input))
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [prepareRequest]
    }
    
    struct PrepareRequest: Equatable {
        let assetsIds: [String]
    }
    
    private lazy var prepareRequest: Feedback = {

        return react(request: { (state) -> PrepareRequest? in

            if case .prepareRequest = state.core.action {
                
                var assetsIds: [String] = []
                
                switch state.core.data.transaction {
                case .send(let tx):
                    assetsIds.append(tx.feeAssetID)
                    assetsIds.append(tx.assetId)
                    
                case .data:
                    assetsIds.append("WAVES")
                    
                case .invokeScript(let tx):
                    assetsIds.append(tx.feeAssetId)
                    let list: [String] = tx.payment.map { $0.assetId }
                    assetsIds.append(contentsOf: list)
                }
                return PrepareRequest(assetsIds: assetsIds)
            }

            return nil

        }, effects: { [weak self] (request) -> Signal<Event> in

            guard let self = self else { return Signal.never() }

            return self
                .assetsUseCase
                .assets(by: request.assetsIds, accountAddress: "")
                .map { Types.Event.prepareRequest($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    

    override func reduce(event: Event, state: inout State) {
        
        switch event {
            
        case .none:
            break
            
        case .prepareRequest(let assets):
            let map = assets.reduce(into: [String: DomainLayer.DTO.Asset].init()) { (result, asset) in
                result[asset.id] = asset
            }
            
            guard let txRequest = state
                .core
                .data
                .transaction
                .transactionDTO(assetsMap: map,
                                signedWallet: state.core.signedWallet)
                else {
                    //TODO: Error?
                    state.ui.action = .update
                    state.core.action = .none
                    return
                }
            
            
            let prepareRequest = ConfirmRequest.DTO.PrepareRequest(transaction: txRequest,
                                                                   data: state.core.data,
                                                                   signedWallet: state.core.signedWallet,
                                                                   timestamp: Date())

            state.ui.sections = sections(request: prepareRequest.request())
            state.ui.action = .update
            state.core.action = .none
            
        case .viewDidAppear:
            state.ui.sections = [Types.Section(rows: [.skeleton])]
            state.ui.action = .update
            state.core.action = .prepareRequest
        }
    }
    
    private func uiState() -> State.UI! {
        return ConfirmRequest.State.UI(sections: [],
                                       action: .none)
    }
    
    private func coreState(input: ConfirmRequest.DTO.Input) -> State.Core! {
        return State.Core(action: .none,
                          data: input.data,
                          signedWallet: input.signedWallet)
    }
    
    private func sections(request: ConfirmRequest.DTO.Request) -> [Types.Section] {
        
        
        let fromTo = ConfirmRequestFromToCell.Model.init(accountName: "Alam",
                                                         address: "a232324234234",
                                                         dAppIcon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdF37xBUCZDiNuteNQRfQBTadMGcv25qpDRir40U5ILLYXp7uL",
                                                         dAppName: "alaxsam")
        
        let keyValue = ConfirmRequestKeyValueCell.Model.init(title: "alamr",
                                                             value: "213123")
        
        let balance = BalanceLabel.Model.init(balance: Balance.init(currency: .init(title: "233", ticker: "sd"),
                                                                    money: Money.init(0, 2)),
                                              sign: .minus,
                                              style: .small)
        
        let fee = ConfirmRequestFeeAndTimestampCell.Model.init(date: Date(), feeBalance: balance)
        
        let balancePay = ConfirmRequestBalanceCell.Model.init(title: "Payment", feeBalance: balance)
        
        
        let kindNew = ConfirmRequestTransactionKindCell.Model.init(title: "Alalal",
                                                                   image: Images.tInvocationscript48.image,
                                                                   info: .balance(balance))
        
        let rows = [Types.Row.transactionKind(request.transaction.transactionKindViewModel),
                    Types.Row.fromTo(fromTo),
                    Types.Row.keyValue(keyValue),
                    .feeAndTimestamp(fee),
                    .balance(balancePay),
                    .buttons]
        
        return [Types.Section(rows: rows)]
    }
}

fileprivate extension ConfirmRequest.DTO.Request {
    
    var fromToViewModel: ConfirmRequestFromToCell.Model {
        ConfirmRequestFromToCell.Model.init(accountName: signedWallet.wallet.name,
                                            address: signedWallet.address,
                                            dAppIcon: data, dAppName: <#T##String#>)
    }
}

fileprivate extension ConfirmRequest.DTO.Transaction  {

    var transactionKindViewModel: ConfirmRequestTransactionKindView.Model {
        return ConfirmRequestTransactionKindView.Model.init(title: titleTransactionKindViewModel,
                                                            image: iconTransactionKindViewModel,
                                                            info: infoTransactionKindViewModel)
    }
    
    var infoTransactionKindViewModel: ConfirmRequestTransactionKindView.Info {
        
        switch self {
        case .data:
            return .descriptionLabel("Data transaction")
            
        case .invokeScript:
            return .descriptionLabel("Script Invocation")
            
        case .transfer(let tx):
            return .balance(.init(balance: Balance.init(currency: .init(title: "Sent",
                                                                        ticker: tx.asset.ticker),
                                                        money: .init(tx.amount.amount,
                                                                     tx.asset.precision)),
                                  sign: .minus,
                                  style: .small))
        }
        
    }
    
    var titleTransactionKindViewModel: String {
        
        switch self {
        case .data:
            return "Entry in blockchain"
            
        case .invokeScript:
            return "Entry in blockchain"
            
        case .transfer:
            return "Sent"
        }
    }
    
    var iconTransactionKindViewModel: UIImage {
        switch self {
        case .data:
            return Images.tData48.image
            
        case .invokeScript:
            return Images.tInvocationscript48.image
            
        case .transfer:
            return Images.tSend48.image
        }
    }
}
    

fileprivate extension WavesKeeper.Transaction.InvokeScript.Arg  {
    
    var argDTO: ConfirmRequest.DTO.InvokeScript.Arg {
        
        switch self.value {
        case .binary(let binary):
            return ConfirmRequest.DTO.InvokeScript.Arg.init(value: .binary(binary))
            
        case .bool(let bool):
            return ConfirmRequest.DTO.InvokeScript.Arg.init(value: .bool(bool))
            
        case .integer(let int):
            return ConfirmRequest.DTO.InvokeScript.Arg.init(value: .integer(int))
            
        case .string(let string):
            return ConfirmRequest.DTO.InvokeScript.Arg.init(value: .string(string))
        }
    }
}

fileprivate extension WavesKeeper.Transaction.InvokeScript.Call  {
    
    
    func invokeScriptCallArgs(assetsMap: [String: DomainLayer.DTO.Asset],
                          signedWallet: DomainLayer.DTO.SignedWallet) -> [ConfirmRequest.DTO.InvokeScript.Arg]? {
        
        return self.args.map { $0.argDTO }
    }
    
    func invokeScriptCall(assetsMap: [String: DomainLayer.DTO.Asset],
                          signedWallet: DomainLayer.DTO.SignedWallet) -> ConfirmRequest.DTO.InvokeScript.Call? {
        
        guard let args = invokeScriptCallArgs(assetsMap: assetsMap,
                                              signedWallet: signedWallet) else { return nil }
        
        return ConfirmRequest.DTO.InvokeScript.Call(function: self.function,
                                                    args: args)
    }
}

fileprivate extension WavesKeeper.Transaction.InvokeScript {
    
    func paymentDTO(assetsMap: [String: DomainLayer.DTO.Asset],
                    signedWallet: DomainLayer.DTO.SignedWallet) -> [ConfirmRequest.DTO.InvokeScript.Payment] {
        
        return self.payment.map { (payment) -> ConfirmRequest.DTO.InvokeScript.Payment? in
            guard let asset = assetsMap[payment.assetId] else { return nil }
        
            let amount = Money(payment.amount, asset.precision)
            return .init(amount: amount, asset: asset)
        }
        .compactMap { $0 }
    }
}


fileprivate extension WavesKeeper.Transaction.Data.Value {
    
    func valueDTO() -> ConfirmRequest.DTO.Data.Value.Kind {
        switch self.value {
        case .binary(let value):
            return .binary(value)
            
        case .boolean(let value):
            return .boolean(value)
        
        case .integer(let value):
            return .integer(value)
            
        case .string(let value):
            return .string(value)
        }
    }
}

fileprivate extension WavesKeeper.Transaction.Data {
    
    func dataDTO() -> [ConfirmRequest.DTO.Data.Value] {
        
        return self.data.map { (data) -> ConfirmRequest.DTO.Data.Value in
            
            return ConfirmRequest.DTO.Data.Value(key: data.key,
                                                 value: data.valueDTO())
            
        }
    }
}

fileprivate extension WavesKeeper.Transaction  {
    
    func transactionDTO(assetsMap: [String: DomainLayer.DTO.Asset],
                        signedWallet: DomainLayer.DTO.SignedWallet) -> ConfirmRequest.DTO.Transaction? {
        
        switch self {
        case .data(let tx):
            
            guard let feeAsset = assetsMap["WAVES"] else { return nil }
            
            let fee = Money(tx.fee, feeAsset.precision)
            
            let data = ConfirmRequest.DTO.Data.init(fee: fee,
                                                    feeAsset: feeAsset,
                                                    data: tx.dataDTO(),
                                                    chainId: tx.chainId)
            
            return .data(data)
            
        case .invokeScript(let tx):
            
            guard let asset = assetsMap["WAVES"] else { return nil }
            guard let feeAsset = assetsMap[tx.feeAssetId] else { return nil }
            
            guard let call = tx.call?.invokeScriptCall(assetsMap: assetsMap, signedWallet: signedWallet) else { return nil }
            
            let fee = Money(tx.fee, feeAsset.precision)
            
            let invokeScript = ConfirmRequest.DTO.InvokeScript(asset: asset,
                                                               fee: fee,
                                                               feeAsset: feeAsset,
                                                               chainId: tx.chainId,
                                                               dApp: tx.dApp,
                                                               call: call,
                                                               payment: tx.paymentDTO(assetsMap: assetsMap,
                                                                                      signedWallet: signedWallet) )
            return .invokeScript(invokeScript)
            
        case .send(let tx):
    
            guard let asset = assetsMap[tx.assetId] else { return nil}
            guard let feeAsset = assetsMap[tx.feeAssetID] else { return nil}
            
            let money = Money(tx.amount, asset.precision)
            let fee = Money(tx.fee, feeAsset.precision)
            
            let transfer: ConfirmRequest.DTO.Transfer = .init(recipient: tx.recipient,
                                                              asset: asset,
                                                              amount: money,
                                                              feeAsset: feeAsset,
                                                              fee: fee,
                                                              attachment: tx.attachment,
                                                              chainId: tx.chainId)
            return .transfer(transfer)
        }
    }
}

fileprivate extension ConfirmRequest.DTO.Data.Value  {
    
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

fileprivate extension ConfirmRequest.DTO.InvokeScript.Arg.Value  {
    
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

fileprivate extension ConfirmRequest.DTO.InvokeScript.Payment {
    
    func paymentSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Payment {
        return .init(amount: amount.amount, assetId: asset.id)
    }
}

fileprivate extension ConfirmRequest.DTO.InvokeScript.Arg {
    
    func argSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg {
        
        return TransactionSignatureV1.Structure.InvokeScript.Arg(value: value.argValueSigantureV1())
    }
}

fileprivate extension ConfirmRequest.DTO.InvokeScript.Call  {
    
    func callSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Call {
        
        return .init(function: function,
                     args: args.map { $0.argSigantureV1() })
    }
    
}

fileprivate extension ConfirmRequest.DTO.PrepareRequest  {

    func request() -> ConfirmRequest.DTO.Request {
        
        let signature: TransactionSignatureProtocol = transactionSignature()
        
        return ConfirmRequest.DTO.Request.init(transaction: transaction,
                                               data: data,
                                               signedWallet: signedWallet,
                                               timestamp: timestamp,
                                               proof: signature.bytesStructure,
                                               txId: signature.id)
    }
    
    func transactionSignature() -> TransactionSignatureProtocol {
        
        switch self.transaction {
        case .data(let tx):
            
            let signature = TransactionSignatureV1.data(.init(fee: tx.fee.amount,
                                                              data: tx.data.map { $0.valueSignatureV1() },
                                                              chainId: tx.chainId,
                                                              senderPublicKey: self.signedWallet.publicKey.getPublicKeyStr(),
                                                              timestamp: self.timestamp.millisecondsSince1970))
            
            return signature
            
        case .invokeScript(let tx):
            
            let signature = TransactionSignatureV1.invokeScript(.init(senderPublicKey: self.signedWallet.publicKey.getPublicKeyStr(),
                                                                      fee: tx.fee.amount,
                                                                      chainId: tx.chainId,
                                                                      timestamp: self.timestamp.millisecondsSince1970,
                                                                      feeAssetId: tx.feeAsset.id,
                                                                      dApp: tx.dApp,
                                                                      call: tx.call?.callSigantureV1(),
                                                                      payment: tx.payment.map { $0.paymentSigantureV1() }))
            
            return signature
        case .transfer(let tx):
            
            let signature = TransactionSignatureV2.transfer(.init(senderPublicKey: self.signedWallet.publicKey.getPublicKeyStr(),
                                                                  recipient: tx.recipient,
                                                                  assetId: tx.asset.id,
                                                                  amount: tx.amount.amount,
                                                                  fee: tx.fee.amount,
                                                                  attachment: tx.attachment,
                                                                  feeAssetID: tx.feeAsset.id,
                                                                  chainId: tx.chainId,
                                                                  timestamp: timestamp.millisecondsSince1970))
            return signature
        }
    }
}
