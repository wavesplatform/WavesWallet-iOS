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
import Base58
import WavesSDK

final class GatewayRepository: GatewayRepositoryProtocol {
   
    private let gatewayProvider: MoyaProvider<Gateway.Service> = .anyMoyaProvider()
    
    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func initWithdrawProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.InitWithdrawProcess> {
        
        let initProcess = Gateway.Service.InitProcess(userAddress: address, assetId: asset.id)
       
        return environmentRepository.servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) -> Observable<DomainLayer.DTO.Gateway.InitWithdrawProcess> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                return self.gatewayProvider.rx
                .request(.initWithdrawProcess(baseURL: url, withdrawProcess: initProcess),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
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
            })
    }

    func initDepositProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.InitDepositProcess> {
        let initProcess = Gateway.Service.InitProcess(userAddress: address, assetId: asset.id)
        
        return environmentRepository.servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) ->  Observable<DomainLayer.DTO.Gateway.InitDepositProcess> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                return self.gatewayProvider.rx
                .request(.initDepositProcess(baseURL: url, depositProcess: initProcess),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Gateway.DTO.Deposit.self)
                    .asObservable()
                    .map({ (initDeposit) -> DomainLayer.DTO.Gateway.InitDepositProcess in
                        
                        return DomainLayer.DTO.Gateway.InitDepositProcess(
                            address: initDeposit.address,
                            minAmount: Money(initDeposit.minAmount, asset.precision),
                            maxAmount: Money(initDeposit.maxAmount, asset.precision))
                    })
        })
    }
    
    
    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<Bool> {

        return environmentRepository
            .servicesEnvironment().flatMap({ [weak self] (servicesEnvironment) -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                let specs = specifications.broadcastSpecification(servicesEnvironment: servicesEnvironment,
                                                                  wallet: wallet,
                                                                  scheme: servicesEnvironment.walletEnvironment.vostokScheme,
                                                                  specifications: specifications)
                
                guard let broadcastSpecification = specs else { return Observable.empty() }
                
                return self.gatewayProvider.rx
                    .request(.send(baseURL: url ,broadcast: broadcastSpecification, accountAddress: wallet.address),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                .filterSuccessfulStatusAndRedirectCodes()
                .asObservable()
                .map({ (response) -> Bool in
                    return true
                })
            })
    }
    
}
