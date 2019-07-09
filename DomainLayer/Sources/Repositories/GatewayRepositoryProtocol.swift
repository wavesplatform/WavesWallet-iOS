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
    
    func startWithdrawProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.StartWithdrawProcess>
    func startDepositProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.StartDepositProcess>
    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<Bool>

}
