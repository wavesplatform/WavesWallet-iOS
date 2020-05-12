//
//  GatewaysWavesApiClientService.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import Foundation
import RxSwift
import WavesSDK

public enum GatewaysWavesError: Error {
    case network(NetworkError)
    case notFound
}

public protocol GatewaysWavesRepository {
    func assetBindingsRequest(serverEnvironment: ServerEnvironment,
                              oAToken: WEOAuthTokenDTO,
                              request: AssetBindingsRequest) -> Observable<[GatewaysAssetBinding]>

    func withdrawalTransferBinding(serverEnvironment: ServerEnvironment,
                                   oAToken: WEOAuthTokenDTO,
                                   request: TransferBindingRequest) -> Observable<GatewaysTransferBinding>

    func depositTransferBinding(serverEnvironment: ServerEnvironment,
                                oAToken: WEOAuthTokenDTO,
                                request: TransferBindingRequest) -> Observable<GatewaysTransferBinding>

    func calculateFee(amount: Int64, direction: AssetBindingsRequest.Direction, assetBinding: GatewaysAssetBinding) -> Money
}
