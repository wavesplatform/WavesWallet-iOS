//
//  GatewayUseCaseProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

public protocol WEGatewayUseCaseProtocol {
    
    func receiveBinding(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding>
    func sendBinding(asset: DomainLayer.DTO.Asset, address: String) -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding>
}
