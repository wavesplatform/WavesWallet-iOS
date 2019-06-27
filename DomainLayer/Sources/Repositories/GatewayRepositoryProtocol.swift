//
//  GatewayRepositoryProtocol.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol GatewayRepositoryProtocol {
    
    func initWithdrawProcess(by address: String, asset: DomainLayer.DTO.Asset, accountAddress: String) -> Observable<DomainLayer.DTO.Gateway.InitWithdrawProcess>
    func sendWithdraw() -> Observable<Bool>
    
}
