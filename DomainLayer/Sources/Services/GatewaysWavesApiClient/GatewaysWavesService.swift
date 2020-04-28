//
//  GatewaysWavesApiClientService.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public protocol GatewaysWavesService {
    
    func assetBindingsRequest(addressGrpc: String,
                              oAToken: String,
                              request: GetWavesAssetBindingsRequest) -> Observable<GetWavesAssetBindingsRequest>
    
    func withdrawalTransferBinding(addressGrpc: String,
                                   oAToken: String,
                                   request: TransferBindingRequest) -> Observable<GatewaysGetTransferBindingResponse>

    func depositTransferBinding(addressGrpc: String,
                                oAToken: String,
                                request: GatewaysGetDepositTransferBindingRequest) -> Observable<GatewaysGetTransferBindingResponse>    
}
