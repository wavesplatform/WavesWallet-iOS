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

//TODO: После переходна grpc надо бы его удалить
public protocol WEGatewayUseCaseProtocol {
    
    func receiveBinding(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.WEGateway.ReceiveBinding>
    func sendBinding(asset: DomainLayer.DTO.Asset, address: String, amount: Money) -> Observable<DomainLayer.DTO.WEGateway.SendBinding>
}
