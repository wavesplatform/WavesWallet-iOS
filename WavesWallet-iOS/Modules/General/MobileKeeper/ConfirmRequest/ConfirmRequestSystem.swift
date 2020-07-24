//
//  ConfirmRequestSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

private typealias Types = ConfirmRequest

final class ConfirmRequestSystem: System<ConfirmRequest.State, ConfirmRequest.Event> {
    private lazy var assetsRepository: AssetsRepositoryProtocol = UseCasesFactory.instance.repositories.assetsRepository
    private lazy var mobileKeeperRepository: MobileKeeperRepositoryProtocol =
        UseCasesFactory.instance.repositories.mobileKeeperRepository

    private let input: ConfirmRequest.DTO.Input

    init(input: ConfirmRequest.DTO.Input) {
        self.input = input
    }

    override func initialState() -> State! {
        ConfirmRequest.State(ui: uiState(), core: coreState(input: input))
    }

    override func internalFeedbacks() -> [Feedback] { [prepareRequest] }

    struct PrepareRequest: Equatable {
        let assetsIds: [String]
        let request: DomainLayer.DTO.MobileKeeper.Request
        let signedWallet: SignedWallet
        let timestamp: Date

        static func == (lhs: PrepareRequest, rhs: PrepareRequest) -> Bool {
            lhs.timestamp == rhs.timestamp
        }
    }

    private lazy var prepareRequest: Feedback = {
        react(request: { state -> PrepareRequest? in

            if case .prepareRequest = state.core.action {
                var assetsIds: [String] = []

                switch state.core.request.transaction {
                case let .send(tx):
                    assetsIds.append(tx.feeAssetID)
                    assetsIds.append(tx.assetId)

                case .data:
                    assetsIds.append(WavesSDKConstants.wavesAssetId)

                case let .invokeScript(tx):
                    assetsIds.append(tx.feeAssetId)
                    let list: [String] = (tx.payment.map { $0.assetId })
                    assetsIds.append(contentsOf: list)
                default:
                    break
                }
                return PrepareRequest(assetsIds: assetsIds,
                                      request: state.core.request,
                                      signedWallet: state.core.signedWallet,
                                      timestamp: state.core.timestamp)
            }

            return nil
        },
              effects: { [weak self] request -> Signal<Event> in

            guard let self = self else { return Signal.never() }

            let prepareRequest = self
                .mobileKeeperRepository
                .prepareRequest(request.request,
                                signedWallet: request.signedWallet,
                                timestamp: request.timestamp)

            let assets = self
                .assetsRepository
                .assets(ids: request.assetsIds, accountAddress: "")
                .map { $0.compactMap { $0 } }

            return Observable.zip(prepareRequest, assets)
                .map { Types.Event.prepareRequest($1, $0) }
                .asSignal(onErrorRecover: { _ in Signal.just(.handlerError) })
        })
    }()

    override func reduce(event: Event, state: inout State) {
        switch event {
        case .handlerError:
            state.ui.action = .closeRequest
            state.core.action = .none

        case .none:
            break

        case let .prepareRequest(assets, prepareRequest):
            let map = assets.reduce(into: [String: Asset]()) { result, asset in
                result[asset.id] = asset
            }

            let maybyTxRequest = state.core.request.transaction.transactionDTO(assetsMap: map,
                                                                               signedWallet: state.core.signedWallet)
            guard let txRequest = maybyTxRequest else {
                // TODO: Error?
                // Transaction not support
                state.ui.action = .closeRequest
                state.core.action = .none
                state.core.prepareRequest = prepareRequest
                return
            }

            let complitingRequest = ConfirmRequest
                .DTO
                .ComplitingRequest(transaction: txRequest,
                                   prepareRequest: prepareRequest,
                                   signedWallet: state.core.signedWallet,
                                   timestamp: prepareRequest.timestamp,
                                   proof: prepareRequest.proof,
                                   txId: prepareRequest.txId)

            state.ui.sections = sections(complitingRequest: complitingRequest)
            state.ui.action = .update
            state.core.action = .none
            state.core.prepareRequest = prepareRequest
            state.core.complitingRequest = complitingRequest

        case .viewDidAppear:
            state.ui.sections = [Types.Section(rows: [.skeleton])]
            state.ui.action = .update
            state.core.action = .prepareRequest
            state.core.timestamp = Date()
        }
    }

    private func uiState() -> State.UI! {
        ConfirmRequest.State.UI(sections: [], action: .none)
    }

    private func coreState(input: ConfirmRequest.DTO.Input) -> State.Core! {
        State.Core(action: .none,
                   request: input.request,
                   signedWallet: input.signedWallet,
                   prepareRequest: nil,
                   complitingRequest: nil,
                   timestamp: Date())
    }

    private func sections(complitingRequest: ConfirmRequest.DTO.ComplitingRequest) -> [Types.Section] {
        var rows: [Types.Row] = [.transactionKind(complitingRequest.transaction.transactionKindViewModel),
                                 .fromTo(complitingRequest.fromToViewModel)]

        switch complitingRequest.transaction {
        case let .invokeScript(tx):

            let address = ConfirmRequestKeyValueCell.Model(title: Localizable.Waves.Transactioncard.Title.scriptAddress,
                                                           value: tx.dApp)

            if let function = tx.call?.function {
                let function = ConfirmRequestKeyValueCell.Model(title: Localizable.Waves.Keeper.Label.function,
                                                                value: function)
                rows.append(.keyValue(function))
            }

            rows.append(.keyValue(address))

            for payment in tx.payment {
                let currency = DomainLayer.DTO.Balance.Currency(title: payment.asset.displayName, ticker: payment.asset.ticker)
                let money = Money(payment.amount.amount, payment.asset.precision)
                let balance = DomainLayer.DTO.Balance(currency: currency, money: money)

                let paymentBalance = BalanceLabel.Model(balance: balance, sign: .minus, style: .small)

                let balanceModel = ConfirmRequestBalanceCell.Model(title: Localizable.Waves.Transactioncard.Title.payment,
                                                                   feeBalance: paymentBalance)

                rows.append(.balance(balanceModel))
            }

        default:
            break
        }

        rows.append(.keyValue(complitingRequest.txIdkeyValueViewModel))
        rows.append(.feeAndTimestamp(complitingRequest.feeAndTimestampViewModel))

        rows.append(.buttons)

        return [Types.Section(rows: rows)]
    }
}

fileprivate extension ConfirmRequest.DTO.ComplitingRequest {
    var feeAndTimestampViewModel: ConfirmRequestFeeAndTimestampCell.Model {
        let feeAsset = transaction.feeAsset
        let fee = transaction.fee

        let currency = DomainLayer.DTO.Balance.Currency(title: feeAsset.displayName, ticker: feeAsset.ticker)
        let money = Money(fee.amount, feeAsset.precision)

        let balance = DomainLayer.DTO.Balance(currency: currency, money: money)

        let feeBalance = BalanceLabel.Model(balance: balance,
                                            sign: DomainLayer.DTO.Balance.Sign.none,
                                            style: .small)

        return ConfirmRequestFeeAndTimestampCell.Model(date: timestamp, feeBalance: feeBalance)
    }

    var fromToViewModel: ConfirmRequestFromToCell.Model {
        ConfirmRequestFromToCell.Model(accountName: signedWallet.wallet.name,
                                       address: signedWallet.address,
                                       dAppIcon: prepareRequest.request.dApp.iconUrl,
                                       dAppName: prepareRequest.request.dApp.name)
    }

    var txIdkeyValueViewModel: ConfirmRequestKeyValueCell.Model {
        ConfirmRequestKeyValueCell.Model(title: Localizable.Waves.Startleasingconfirmation.Label.txid, value: txId)
    }
}

fileprivate extension InvokeScriptTransactionSender.Arg {
    var argDTO: ConfirmRequest.DTO.InvokeScript.Arg {
        switch value {
        case let .binary(binary):
            return ConfirmRequest.DTO.InvokeScript.Arg(value: .binary(binary))

        case let .bool(bool):
            return ConfirmRequest.DTO.InvokeScript.Arg(value: .bool(bool))

        case let .integer(int):
            return ConfirmRequest.DTO.InvokeScript.Arg(value: .integer(int))

        case let .string(string):
            return ConfirmRequest.DTO.InvokeScript.Arg(value: .string(string))
        }
    }
}

fileprivate extension InvokeScriptTransactionSender.Call {
    func invokeScriptCallArgs(assetsMap _: [String: Asset],
                              signedWallet _: SignedWallet) -> [ConfirmRequest.DTO.InvokeScript.Arg]? {
        args.map { $0.argDTO }
    }

    func invokeScriptCall(assetsMap: [String: Asset],
                          signedWallet: SignedWallet) -> ConfirmRequest.DTO.InvokeScript.Call? {
        guard let args = invokeScriptCallArgs(assetsMap: assetsMap, signedWallet: signedWallet) else { return nil }

        return ConfirmRequest.DTO.InvokeScript.Call(function: function, args: args)
    }
}

fileprivate extension InvokeScriptTransactionSender {
    func paymentDTO(assetsMap: [String: Asset],
                    signedWallet _: SignedWallet) -> [ConfirmRequest.DTO.InvokeScript.Payment] {
        payment.compactMap { payment -> ConfirmRequest.DTO.InvokeScript.Payment? in
            guard let asset = assetsMap[payment.assetId] else { return nil }

            let amount = Money(payment.amount, asset.precision)
            return .init(amount: amount, asset: asset)
        }
    }
}

fileprivate extension DataTransactionSender.Value {
    func valueDTO() -> ConfirmRequest.DTO.Data.Value.Kind? {
        guard let value = self.value else { return nil }
        switch value {
        case let .binary(value):
            return .binary(value)

        case let .boolean(value):
            return .boolean(value)

        case let .integer(value):
            return .integer(value)

        case let .string(value):
            return .string(value)
        }
    }
}

fileprivate extension DataTransactionSender {
    func dataDTO() -> [ConfirmRequest.DTO.Data.Value] {
        data.map { data -> ConfirmRequest.DTO.Data.Value in
            ConfirmRequest.DTO.Data.Value(key: data.key, value: data.valueDTO())
        }
    }
}

fileprivate extension TransactionSenderSpecifications {
    func transactionDTO(assetsMap: [String: Asset],
                        signedWallet: SignedWallet) -> ConfirmRequest.DTO.Transaction? {
        switch self {
        case let .data(tx):

            guard let feeAsset = assetsMap[WavesSDKConstants.wavesAssetId] else { return nil }

            let fee = Money(tx.fee, feeAsset.precision)

            let data = ConfirmRequest.DTO.Data(fee: fee,
                                               feeAsset: feeAsset,
                                               data: tx.dataDTO(),
                                               chainId: tx.chainId ?? 0)

            return .data(data)

        case let .invokeScript(tx):

            guard let asset = assetsMap[WavesSDKConstants.wavesAssetId] else { return nil }
            guard let feeAsset = assetsMap[tx.feeAssetId] else { return nil }

            guard let call = tx.call?.invokeScriptCall(assetsMap: assetsMap, signedWallet: signedWallet) else { return nil }

            let fee = Money(tx.fee, feeAsset.precision)

            let invokeScript = ConfirmRequest.DTO.InvokeScript(asset: asset,
                                                               fee: fee,
                                                               feeAsset: feeAsset,
                                                               chainId: tx.chainId ?? 0,
                                                               dApp: tx.dApp,
                                                               call: call,
                                                               payment: tx.paymentDTO(assetsMap: assetsMap,
                                                                                      signedWallet: signedWallet))
            return .invokeScript(invokeScript)

        case let .send(tx):

            guard let asset = assetsMap[tx.assetId] else { return nil }
            guard let feeAsset = assetsMap[tx.feeAssetID] else { return nil }

            let money = Money(tx.amount, asset.precision)
            let fee = Money(tx.fee, feeAsset.precision)

            let transfer: ConfirmRequest.DTO.Transfer = .init(recipient: tx.recipient,
                                                              asset: asset,
                                                              amount: money,
                                                              feeAsset: feeAsset,
                                                              fee: fee,
                                                              attachment: tx.attachment,
                                                              chainId: tx.chainId ?? 0)
            return .transfer(transfer)

        default:
            return nil
        }
    }
}
