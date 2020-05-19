//
//  SendInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

final class SendInteractor: SendInteractorProtocol {
    private let accountBalanceUseCase: AccountBalanceUseCaseProtocol
    private let assetsUseCase: AssetsUseCaseProtocol
    private let authorizationUseCase: AuthorizationUseCaseProtocol
    private let coinomatRepository: CoinomatRepositoryProtocol
    private let aliasRepository: AliasesRepositoryProtocol
    private let transactionUseCase: TransactionsUseCaseProtocol
    private let gatewayRepository: GatewayRepositoryProtocol
    private let weGatewayUseCase: WEGatewayUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository
    private let weOAuthRepository: WEOAuthRepositoryProtocol
    private let gatewaysWavesRepository: GatewaysWavesRepository

    init(gatewaysWavesRepository: GatewaysWavesRepository,
         assetsUseCase: AssetsUseCaseProtocol,
         authorizationUseCase: AuthorizationUseCaseProtocol,
         coinomatRepository: CoinomatRepositoryProtocol,
         aliasRepository: AliasesRepositoryProtocol,
         transactionUseCase: TransactionsUseCaseProtocol,
         accountBalanceUseCase: AccountBalanceUseCaseProtocol,
         gatewayRepository: GatewayRepositoryProtocol,
         weGatewayUseCase: WEGatewayUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository,
         weOAuthRepository: WEOAuthRepositoryProtocol) {
        self.accountBalanceUseCase = accountBalanceUseCase
        self.assetsUseCase = assetsUseCase
        self.authorizationUseCase = authorizationUseCase
        self.coinomatRepository = coinomatRepository
        self.aliasRepository = aliasRepository
        self.transactionUseCase = transactionUseCase
        self.gatewayRepository = gatewayRepository
        self.weGatewayUseCase = weGatewayUseCase
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
        self.weOAuthRepository = weOAuthRepository
        self.gatewaysWavesRepository = gatewaysWavesRepository
    }

    func assetBalance(by assetID: String) -> Observable<DomainLayer.DTO.SmartAssetBalance?> {
        return accountBalanceUseCase.balances()
            .flatMap { [weak self] (balances) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in

                if let asset = balances.first(where: { $0.assetId == assetID }) {
                    return Observable.just(asset)
                }

                guard let self = self else { return Observable.empty() }
                return self.authorizationUseCase.authorizedWallet()
                    .flatMap { [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                        guard let self = self else { return Observable.empty() }
                        return self.assetsUseCase.assets(by: [assetID], accountAddress: wallet.address)
                            .flatMap { (assets) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in

                                var assetBalance: DomainLayer.DTO.SmartAssetBalance?
                                if let asset = assets.first(where: { $0.id == assetID }) {
                                    assetBalance = .init(assetId: asset.id,
                                                         totalBalance: 0,
                                                         leasedBalance: 0,
                                                         inOrderBalance: 0,
                                                         settings: .init(assetId: asset.id, sortLevel: 0, isHidden: false,
                                                                         isFavorite: false),
                                                         asset: asset,
                                                         modified: asset.modified,
                                                         sponsorBalance: 0)
                                }
                                return Observable.just(assetBalance)
                            }
                    }
            }.catchError { (_) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                Observable.just(nil)
            }
    }

    func calculateFee(assetID: String) -> Observable<Money> {
        return authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<Money> in
                guard let self = self else { return Observable.empty() }
                return self.transactionUseCase
                    .calculateFee(by: .sendTransaction(assetID: assetID), accountAddress: wallet.address)
            }
    }

    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        // TODO: need optimization

        return accountBalanceUseCase.balances()
            .flatMap { balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in

                guard let wavesAsset = balances.first(where: { $0.asset.wavesId == WavesSDKConstants.wavesAssetId }) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
            }
    }

    func validateAlis(alias: String) -> Observable<Bool> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()
        return Observable.zip(serverEnvironment, wallet)
            .flatMap { [weak self] serverEnvironment, wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }

                return self.aliasRepository
                    .alias(serverEnvironment: serverEnvironment,
                           name: alias,
                           accountAddress: wallet.address)
                    .flatMap { (_) -> Observable<Bool> in
                        Observable.just(true)
                    }
            }
            .catchError { (_) -> Observable<Bool> in
                Observable.just(false)
            }
    }

    func send(fee: Money,
              recipient: String,
              asset: Asset,
              amount: Money,
              attachment: String,
              feeAssetID: String,
              isGatewayTransaction: Bool) -> Observable<Send.TransactionStatus> {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()

        return Observable.zip(wallet, serverEnviroment)
            .flatMap { [weak self] wallet, serverEnviroment -> Observable<Send.TransactionStatus> in

                guard let self = self else { return Observable.empty() }

                let assetId = asset.isWaves ? "" : asset.id

                let sender = SendTransactionSender(recipient: recipient,
                                                   assetId: assetId,
                                                   amount: amount.amount,
                                                   fee: fee.amount,
                                                   attachment: attachment,
                                                   feeAssetID: feeAssetID)

                if isGatewayTransaction {
                    guard let gatewayType = asset.gatewayType else { return Observable.empty() }

                    switch gatewayType {
                    case .exchange:

                        return self.transactionUseCase.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                            .flatMap { (_) -> Observable<Send.TransactionStatus> in
                                Observable.just(.success)
                            }
                    case .coinomat:
                        return self.transactionUseCase.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                            .flatMap { (_) -> Observable<Send.TransactionStatus> in
                                Observable.just(.success)
                            }
                    case .gateway:
                        return self.gatewayRepository.send(serverEnvironment: serverEnviroment,
                                                           specifications: TransactionSenderSpecifications.send(sender),
                                                           wallet: wallet)
                            .flatMap { (_) -> Observable<Send.TransactionStatus> in
                                Observable.just(.success)
                            }
                    }
                } else {
                    return self.transactionUseCase.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                        .flatMap { (_) -> Observable<Send.TransactionStatus> in
                            Observable.just(.success)
                        }
                }
            }
            .catchError { (error) -> Observable<Send.TransactionStatus> in
                if let error = error as? NetworkError {
                    return Observable.just(.error(error))
                }
                return Observable.just(.error(NetworkError.error(by: error)))
            }
    }

    func getDecimalsForAsset(assetID: String) -> Observable<Int> {
        return authorizationUseCase.authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<Int> in
                guard let self = self else { return Observable.empty() }
                return self.assetsUseCase.assets(by: [assetID], accountAddress: wallet.address)
                    .map { (assets) -> Int in
                        assets.first(where: { $0.id == assetID }).map { $0.precision } ?? 0
                    }
            }
            .catchError { (_) -> Observable<Int> in
                Observable.just(0)
            }
    }
}

extension SendInteractor {
    func gateWayInfo(asset: Asset,
                     address: String,
                     amount: Money) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
        guard let gateWayType = asset.gatewayType else { return Observable.empty() }

        switch gateWayType {
        case .exchange:

            let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()
            let authorizedWallet = authorizationUseCase.authorizedWallet()

            return Observable.zip(serverEnvironment, authorizedWallet)
                .flatMap { [weak self] serverEnvironment, wallet -> Observable<(ServerEnvironment, WEOAuthTokenDTO,
                                                                                DomainLayer.DTO.SignedWallet)> in

                guard let self = self else { return Observable.never() }

                return self.weOAuthRepository
                    .oauthToken(signedWallet: wallet)
                    .map { (serverEnvironment, $0, wallet) }
                }
                .flatMap { [weak self] serverEnvironment, token, _ -> Observable<ResponseType<Send.DTO.GatewayInfo>> in

                    guard let self = self else { return Observable.never() }

                    let assetBindingsRequest = AssetBindingsRequest(assetType: .crypto,
                                                                    direction: .withdraw,
                                                                    includesWavesAsset: asset.id)

                    return self
                        .gatewaysWavesRepository.assetBindingsRequest(serverEnvironment: serverEnvironment,
                                                                      oAToken: token,
                                                                      request: assetBindingsRequest)
                        .flatMap { [weak self] assetsBinding -> Observable<ResponseType<Send.DTO.GatewayInfo>> in

                            guard let self = self else { return Observable.never() }

                            guard let assetBinding = assetsBinding.first else { return Observable.error(NetworkError.notFound) }

                            let request = TransferBindingRequest(asset: assetBinding.recipientAsset.asset,
                                                                 recipientAddress: address)

                            return self
                                .gatewaysWavesRepository
                                .withdrawalTransferBinding(serverEnvironment: serverEnvironment,
                                                           oAToken: token,
                                                           request: request)
                                .map { transferBinding -> ResponseType<Send.DTO.GatewayInfo> in

                                    let minAmount = Money(transferBinding.assetBinding.senderAmountMin.int64Value,
                                                          asset.precision)
                                    let maxAmount = Money(transferBinding.assetBinding.senderAmountMax.int64Value,
                                                          asset.precision)

                                    let fee = self.gatewaysWavesRepository
                                        .calculateFee(amount: amount.amount, direction: .withdraw,
                                                      assetBinding: assetBinding)

                                    let info = Send.DTO.GatewayInfo(assetName: asset.name,
                                                                    assetShortName: asset.ticker ?? asset.name,
                                                                    minAmount: minAmount,
                                                                    maxAmount: maxAmount,
                                                                    fee: fee,
                                                                    address: address,
                                                                    attachment: "")
                                    return ResponseType(output: info,
                                                        error: nil)
                                }
                        }
                }

        case .gateway:
            return serverEnvironmentUseCase
                .serverEnvironment()
                .flatMap { [weak self] serverEnvironment -> Observable<DomainLayer.DTO.Gateway.StartWithdrawProcess> in

                    guard let self = self else { return Observable.never() }

                    return self
                        .gatewayRepository
                        .startWithdrawProcess(serverEnvironment: serverEnvironment,
                                              address: address,
                                              asset: asset)
                }
                .map { (startProcessInfo) -> ResponseType<Send.DTO.GatewayInfo> in

                    let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                           assetShortName: asset.ticker ?? "",
                                                           minAmount: startProcessInfo.minAmount,
                                                           maxAmount: startProcessInfo.maxAmount,
                                                           fee: startProcessInfo.fee,
                                                           address: startProcessInfo.recipientAddress,
                                                           attachment: startProcessInfo.processId)
                    return ResponseType(output: gatewayInfo, error: nil)
                }
                .catchError { (error) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in
                    if let networkError = error as? NetworkError {
                        return Observable.just(ResponseType(output: nil, error: networkError))
                    }

                    return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                }

        case .coinomat:
            guard let currencyFrom = asset.wavesId,
                let currencyTo = asset.gatewayId else { return Observable.empty() }

            let tunnel = coinomatRepository.tunnelInfo(asset: asset,
                                                       currencyFrom: currencyFrom,
                                                       currencyTo: currencyTo,
                                                       walletTo: address)

            let rate = coinomatRepository.getRate(asset: asset)

            return Observable.zip(tunnel, rate)
                .flatMap { (tunnel, rate) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in

                    let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                           assetShortName: currencyTo,
                                                           minAmount: rate.min,
                                                           maxAmount: rate.max,
                                                           fee: rate.fee,
                                                           address: tunnel.address,
                                                           attachment: tunnel.attachment)
                    return Observable.just(ResponseType(output: gatewayInfo, error: nil))
                }
                .catchError { (error) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in
                    if let networkError = error as? NetworkError {
                        return Observable.just(ResponseType(output: nil, error: networkError))
                    }

                    return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                }
        }
    }
}
