//
//  GatewaysWavesApiClientService.swift
//  DataLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import GRPC
import NIOHPACK
import NIOHTTP1
import NIOHTTP2
import RxSwift
import SwiftProtobuf
import WavesSDK
import WavesSDKCrypto

final class GatewaysWavesRepositoryImp: GatewaysWavesRepository {
    func assetBindingsRequest(serverEnvironment: ServerEnvironment,
                              oAToken: WEOAuthTokenDTO,
                              request: AssetBindingsRequest) -> Observable<[GatewaysAssetBinding]> {
        var requestBindings = Gateways_GetWavesAssetBindingsRequest()

        if let includesExternalAssetTicker = request.includesExternalAssetTicker {
            requestBindings.includesExternalAssetTicker = includesExternalAssetTicker
        }

        if let includesWavesAsset = request.includesWavesAsset {
            requestBindings.includesWavesAsset = includesWavesAsset
        }

        switch request.direction {
        case .deposit:
            requestBindings.direction = .deposit

        case .withdraw:
            requestBindings.direction = .withdrawal
        }

        let accessToken = oAToken.accessToken
        let addressGrpc = serverEnvironment.servers.wavesExchangeGrpcAddress

        return getWavesAssetBindingsRequest(addressGrpc: addressGrpc, oAToken: accessToken, request: requestBindings)
            .map { response -> [GatewaysAssetBinding] in
                response.gatewaysAssetsBinding
            }
            .catchError { error -> Observable<[GatewaysAssetBinding]> in
                Observable.error(NetworkError.error(by: error))
            }
    }

    func withdrawalTransferBinding(serverEnvironment: ServerEnvironment,
                                   oAToken: WEOAuthTokenDTO,
                                   request: TransferBindingRequest) -> Observable<GatewaysTransferBinding> {
        let accessToken = oAToken.accessToken
        let addressGrpc = serverEnvironment.servers.wavesExchangeGrpcAddress

        var bindingRequest = Gateways_GetWithdrawalTransferBindingRequest()
        bindingRequest.asset = request.asset
        bindingRequest.recipientAddress = request.recipientAddress

        return getWithdrawalTransferBinding(addressGrpc: addressGrpc,
                                            oAToken: accessToken,
                                            request: bindingRequest)
            .map { response -> GatewaysTransferBinding in
                response.transferBinding.gatewaysTransferBinding
            }
            .catchError { [weak self] error -> Observable<GatewaysTransferBinding> in

                guard let self = self else { return Observable.never() }

                // если сервер отдал notFound, то нужно создать биндинг самому
                guard let status = error as? GRPCStatus, status.code == .notFound else {
                    return Observable.error(NetworkError.notFound)
                }

                var bindingRequest = Gateways_CreateWithdrawalTransferBindingRequest()
                bindingRequest.asset = request.asset
                bindingRequest.recipientAddress = request.recipientAddress

                return self.createWithdrawalTransferBinding(addressGrpc: addressGrpc,
                                                            oAToken: accessToken,
                                                            request: bindingRequest)
                    .map { response -> GatewaysTransferBinding in
                        response.transferBinding.gatewaysTransferBinding
                    }
                    .catchError { error -> Observable<GatewaysTransferBinding> in
                        Observable.error(NetworkError.error(by: error))
                    }
            }
    }

    func depositTransferBinding(serverEnvironment: ServerEnvironment,
                                oAToken: WEOAuthTokenDTO,
                                request: TransferBindingRequest) -> Observable<GatewaysTransferBinding> {
        let accessToken = oAToken.accessToken
        let addressGrpc = serverEnvironment.servers.wavesExchangeGrpcAddress

        var bindingRequest = Gateways_GetDepositTransferBindingRequest()
        bindingRequest.asset = request.asset
        bindingRequest.recipientAddress = request.recipientAddress

        return getDepositTransferBinding(addressGrpc: addressGrpc,
                                         oAToken: accessToken,
                                         request: bindingRequest)
            .map { response -> GatewaysTransferBinding in
                response.transferBinding.gatewaysTransferBinding
            }
            .catchError { [weak self] error -> Observable<GatewaysTransferBinding> in

                // если сервер отдал notFound, то нужно создать биндинг самому
                guard let status = error as? GRPCStatus, status.code == .notFound else {
                    return Observable.error(NetworkError.notFound)
                }

                guard let self = self else { return Observable.never() }

                var bindingRequest = Gateways_CreateDepositTransferBindingRequest()
                bindingRequest.asset = request.asset
                bindingRequest.recipientAddress = request.recipientAddress

                return self.createDepositTransferBinding(addressGrpc: addressGrpc,
                                                         oAToken: accessToken,
                                                         request: bindingRequest)
                    .map { response -> GatewaysTransferBinding in
                        response.transferBinding.gatewaysTransferBinding
                    }
            }
            .catchError { error -> Observable<GatewaysTransferBinding> in
                Observable.error(NetworkError.error(by: error))
            }
    }
}

private extension GatewaysWavesRepositoryImp {
    func getWavesAssetBindingsRequest(
        addressGrpc: String,
        oAToken: String,
        request: Gateways_GetWavesAssetBindingsRequest) -> Observable<Gateways_AssetBindingsResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getWavesAssetBindings(request, callOptions: nil)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func getWithdrawalTransferBinding(
        addressGrpc: String,
        oAToken: String,
        request: Gateways_GetWithdrawalTransferBindingRequest) -> Observable<Gateways_GetTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getWithdrawalTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func createWithdrawalTransferBinding(
        addressGrpc: String,
        oAToken: String,
        request: Gateways_CreateWithdrawalTransferBindingRequest) -> Observable<Gateways_CreateTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .createWithdrawalTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func getDepositTransferBinding(
        addressGrpc: String,
        oAToken: String,
        request: Gateways_GetDepositTransferBindingRequest) -> Observable<Gateways_GetTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getDepositTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func createDepositTransferBinding(
        addressGrpc: String,
        oAToken: String,
        request: Gateways_CreateDepositTransferBindingRequest) -> Observable<Gateways_CreateTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .createDepositTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    private func grpcClient<Client: GRPCClient>(address: String,
                                                oAToken: String) -> Client {
        var headers = HPACKHeaders()
        headers.add(name: "Authorization",
                    value: "Bearer \(oAToken)")

        let callOptions = CallOptions(customMetadata: headers)

        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let tls = ClientConnection.Configuration.TLS()

        let configuration = ClientConnection.Configuration(target: .hostAndPort(address, 443),
                                                           eventLoopGroup: group,
                                                           tls: tls)

        let connect = ClientConnection(configuration: configuration)

        return Client(channel: connect, defaultCallOptions: callOptions)
    }
}

fileprivate extension Gateways_Asset {
    var gatewaysAsset: GatewaysAsset {
        let type: GatewaysAsset.TypeAsset = {
            switch self.type {
            case .crypto: return .crypto
            case .fiat: return .fiat
            case let .UNRECOGNIZED(value): return .unrecognized(value)
            }
        }()

        return GatewaysAsset(asset: asset, decimals: decimals, ticker: ticker, type: type)
    }
}

fileprivate extension Gateways_AssetBinding {
    var gatewaysAssetBinding: GatewaysAssetBinding {
        let senderAsset = self.senderAsset.gatewaysAsset
        let recipientAsset = self.recipientAsset.gatewaysAsset

        return GatewaysAssetBinding(senderAsset: senderAsset,
                                    recipientAsset: recipientAsset,
                                    hasRecipientAsset: hasRecipientAsset,
                                    senderAmountMin: senderAmountMin.decodeInt64(),
                                    senderAmountMax: senderAmountMax.decodeInt64(),
                                    taxFlat: taxFlat.decodeInt64(),
                                    taxRate: taxRate,
                                    active: active)
    }
}

fileprivate extension Gateways_AssetBindingsResponse {
    var gatewaysAssetsBinding: [GatewaysAssetBinding] {
        return assetBindings.map { $0.gatewaysAssetBinding }
    }
}

fileprivate extension Gateways_TransferBinding {
    var gatewaysTransferBinding: GatewaysTransferBinding {
        let assetBinding = self.assetBinding.gatewaysAssetBinding

        return .init(assetBinding: assetBinding,
                     addresses: addresses,
                     recipient: recipient)
    }
}
