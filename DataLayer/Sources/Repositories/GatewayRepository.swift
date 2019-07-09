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
import WavesSDK

final class GatewayRepository: GatewayRepositoryProtocol {
   
    private let gatewayProvider: MoyaProvider<Gateway.Service> = .anyMoyaProvider()
    
    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func startWithdrawProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.StartWithdrawProcess> {
        
        let startProcess = Gateway.Service.StartProcess(userAddress: address, assetId: asset.id)
       
        return environmentRepository.servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) -> Observable<DomainLayer.DTO.Gateway.StartWithdrawProcess> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                return self.gatewayProvider.rx
                .request(.startWithdrawProcess(baseURL: url, withdrawProcess: startProcess),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Gateway.DTO.Withdraw.self)
                    .asObservable()
                    .map({ (startWithdraw) -> DomainLayer.DTO.Gateway.StartWithdrawProcess in
                        return DomainLayer.DTO.Gateway.StartWithdrawProcess(
                            recipientAddress: startWithdraw.recipientAddress,
                            minAmount: Money(startWithdraw.minAmount, asset.precision),
                            maxAmount:  Money(startWithdraw.maxAmount, asset.precision),
                            fee:  Money(startWithdraw.fee, asset.precision),
                            processId: startWithdraw.processId)
                        
                    })
            })
    }

    func startDepositProcess(address: String, asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Gateway.StartDepositProcess> {
        let startProcess = Gateway.Service.StartProcess(userAddress: address, assetId: asset.id)
        
        return environmentRepository.servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) ->  Observable<DomainLayer.DTO.Gateway.StartDepositProcess> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                return self.gatewayProvider.rx
                .request(.startDepositProcess(baseURL: url, depositProcess: startProcess),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Gateway.DTO.Deposit.self)
                    .asObservable()
                    .map({ (startDeposit) -> DomainLayer.DTO.Gateway.StartDepositProcess in
                        
                        return DomainLayer.DTO.Gateway.StartDepositProcess(
                            address: startDeposit.address,
                            minAmount: Money(startDeposit.minAmount, asset.precision),
                            maxAmount: Money(startDeposit.maxAmount, asset.precision))
                    })
        })
    }
    
    
    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<Bool> {

        return environmentRepository
            .servicesEnvironment().flatMap({ [weak self] (servicesEnvironment) -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gatewayUrl

                //TODO: - remove vostok scheme
                let specs = specifications.broadcastSpecification(servicesEnvironment: servicesEnvironment,
                                                                  wallet: wallet,
                                                                  specifications: specifications)
                
                guard let broadcastSpecification = specs else { return Observable.empty() }
                
                return self.gatewayProvider.rx
                    .request(.send(baseURL: url, transaction: broadcastSpecification, accountAddress: wallet.address),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                .filterSuccessfulStatusAndRedirectCodes()
                .asObservable()
                .map({ (response) -> Bool in
                    return true
                })
            })
    }
    
}
