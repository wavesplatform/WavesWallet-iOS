//
//  GatewayRepository.swift
//  InternalDataLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Moya
import Extensions

final class GatewayRepository: GatewayRepositoryProtocol {
   
    private let gatewayProvider: MoyaProvider<Gateway.Service> = .anyMoyaProvider()
    
    func initWithdrawProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.InitWithdrawProcess> {
        
        let initProcess = Gateway.Service.InitProcess(userAddress: address, assetId: asset.id)
        return gatewayProvider.rx
            .request(.initWithdrawProcess(initProcess), callbackQueue:  DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Gateway.DTO.Withdraw.self)
            .asObservable()
            .map({ (initWithdraw) -> DomainLayer.DTO.Gateway.InitWithdrawProcess in
                return DomainLayer.DTO.Gateway.InitWithdrawProcess(
                    recipientAddress: initWithdraw.recipientAddress,
                    minAmount: Money(initWithdraw.minAmount, asset.precision),
                    maxAmount:  Money(initWithdraw.maxAmount, asset.precision),
                    fee:  Money(initWithdraw.fee, asset.precision),
                    processId: initWithdraw.processId)
                
            })
    }

    func initDepositProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.InitDepositProcess> {
        let initProcess = Gateway.Service.InitProcess(userAddress: address, assetId: asset.id)
        return gatewayProvider.rx
            .request(.initDepositProcess(initProcess), callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Gateway.DTO.Deposit.self)
            .asObservable()
            .map({ (initDeposit) -> DomainLayer.DTO.Gateway.InitDepositProcess in
                
                return DomainLayer.DTO.Gateway.InitDepositProcess(
                    address: initDeposit.address,
                    minAmount: Money(initDeposit.minAmount, asset.precision),
                    maxAmount: Money(initDeposit.maxAmount, asset.precision))
            })
    }
    
    
    func sendWithdraw() -> Observable<Bool> {
        
        return Observable.empty()
    }
    
}
