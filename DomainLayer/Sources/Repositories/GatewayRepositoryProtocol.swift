//
//  GatewayRepositoryProtocol.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol GatewayRepositoryProtocol {
    
    func startWithdrawProcess(serverEnvironment: ServerEnvironment,
                              address: String,
                              asset: Asset) -> Observable<DomainLayer.DTO.Gateway.StartWithdrawProcess>
    
    func startDepositProcess(serverEnvironment: ServerEnvironment,
                             address: String,
                             asset: Asset) -> Observable<DomainLayer.DTO.Gateway.StartDepositProcess>
    
    func send(serverEnvironment: ServerEnvironment,
              specifications: TransactionSenderSpecifications,
              wallet: SignedWallet) -> Observable<Bool>
}
