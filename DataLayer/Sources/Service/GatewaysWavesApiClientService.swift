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

// Это оберка для GRPC, но будет использоваться только в DataLayer
// Делать свои DTO модели не вижу смысла так как вне DataLayer использоватся не будет

final class GatewaysWavesServiceImp: GatewaysWavesService {
    
    func assetBindingsRequest(addressGrpc: String,
                              oAToken: String,
                              request: GetWavesAssetBindingsRequest) -> Observable<GetWavesAssetBindingsRequest> {
        
        return Observable.never()
    }
    
    func withdrawalTransferBinding(addressGrpc: String,
                                   oAToken: String,
                                   request: TransferBindingRequest) -> Observable<GatewaysGetTransferBindingResponse> {
        return Observable.never()
    }

    func depositTransferBinding(addressGrpc: String,
                                oAToken: String,
                                request: GatewaysGetDepositTransferBindingRequest) -> Observable<GatewaysGetTransferBindingResponse> {
        return Observable.never()
    }
    
        
    
    func getWavesAssetBindingsRequest(addressGrpc: String,
                                      oAToken: String,
                                      request: GetWavesAssetBindingsRequest) -> Observable<GetWavesAssetBindingsRequest> {
        
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        var request = Gateways_GetWavesAssetBindingsRequest()

        request.direction = direction
        request.includesWavesAsset = includesWavesAsset

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getWavesAssetBindings(request, callOptions: nil)
                    .response
                    .wait()

//                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                print(e)
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func getWithdrawalTransferBinding(addressGrpc: String,
                                      recipientAddress: String,
                                      asset: String,
                                      oAToken: String) -> Observable<Gateways_GetTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        var request = Gateways_GetWithdrawalTransferBindingRequest()

        request.recipientAddress = recipientAddress
        request.asset = asset

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getWithdrawalTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                print(e)
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func createWithdrawalTransferBinding(addressGrpc: String,
                                         recipientAddress: String,
                                         asset: String,
                                         oAToken: String) -> Observable<Gateways_CreateTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        var request = Gateways_CreateWithdrawalTransferBindingRequest()

        request.recipientAddress = recipientAddress
        request.asset = asset

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .createWithdrawalTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                print(e)
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func getDepositTransferBinding(addressGrpc: String,
                                   recipientAddress: String,
                                   asset: String,
                                   oAToken: String) -> Observable<Gateways_GetTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        var request = Gateways_GetDepositTransferBindingRequest()

        request.recipientAddress = recipientAddress
        request.asset = asset

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .getDepositTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                print(e)
                observer.onError(e)
            }

            return Disposables.create()
        }
    }

    func createDepositTransferBinding(addressGrpc: String,
                                      recipientAddress: String,
                                      asset: String,
                                      oAToken: String) -> Observable<Gateways_CreateTransferBindingResponse> {
        let gatewaysWavesApiClient: Gateways_WavesApiClient = grpcClient(address: addressGrpc,
                                                                         oAToken: oAToken)

        var request = Gateways_CreateDepositTransferBindingRequest()

        request.recipientAddress = recipientAddress
        request.asset = asset

        return Observable.create { observer -> Disposable in

            do {
                let response = try gatewaysWavesApiClient
                    .createDepositTransferBinding(request)
                    .response
                    .wait()

                observer.onNext(response)
                observer.onCompleted()

            } catch let e {
                print(e)
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
