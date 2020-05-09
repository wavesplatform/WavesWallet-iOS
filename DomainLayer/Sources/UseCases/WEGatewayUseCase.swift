//
//  WEGatewayUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import WavesSDK

//TODO: После переходна grpc надо бы его удалить
final class WEGatewayUseCase: WEGatewayUseCaseProtocol {
    
    private let gatewayRepository: WEGatewayRepositoryProtocol
    private let oAuthRepository: WEOAuthRepositoryProtocol
    private let authorizationUseCase: AuthorizationUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase
    
    init(gatewayRepository: WEGatewayRepositoryProtocol,
         oAuthRepository: WEOAuthRepositoryProtocol,
         authorizationUseCase: AuthorizationUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase) {
        self.gatewayRepository = gatewayRepository
        self.oAuthRepository = oAuthRepository
        self.authorizationUseCase = authorizationUseCase
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }
    
    func receiveBinding(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.WEGateway.ReceiveBinding> {
        
        let serverEnvironment = self.serverEnvironmentUseCase.serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()
        
        return Observable.zip(wallet, serverEnvironment)
            .flatMap { [weak self] signedWallet, serverEnvironment -> Observable<DomainLayer.DTO.WEGateway.ReceiveBinding> in
                
                guard let self = self else { return Observable.never() }
                                
                let oauthToken = self.oAuthRepository.oauthToken(serverEnvironment: serverEnvironment,
                                                                 signedWallet: signedWallet)
                
                return oauthToken
                    .flatMap { [weak self] token -> Observable<DomainLayer.DTO.WEGateway.ReceiveBinding> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        return self.gatewayRepository.transferBinding(serverEnvironment: serverEnvironment,
                                                                      request: .init(senderAsset: asset.gatewayId ?? "",
                                                                                     recipientAsset: asset.id,
                                                                                     recipientAddress: signedWallet.address,
                                                                                     token: token))
                            .map { (transferBindig) -> DomainLayer.DTO.WEGateway.ReceiveBinding in

                                return DomainLayer.DTO.WEGateway.ReceiveBinding(addresses: transferBindig.addresses,
                                                                                      amountMin: Money(transferBindig.amountMin,
                                                                                                       asset.precision),
                                                                                      amountMax: Money(transferBindig.amountMax,
                                                                                                     asset.precision))
                            }
                    }
                    .catchError { (error) -> Observable<DomainLayer.DTO.WEGateway.ReceiveBinding> in
                        return Observable.error(NetworkError.error(by: error))
                    }
        }
    }
    
    func sendBinding(asset: DomainLayer.DTO.Asset,
                     address: String,
                     amount: Money) -> Observable<DomainLayer.DTO.WEGateway.SendBinding> {
        
        let serverEnvironment = self.serverEnvironmentUseCase.serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()
        
        return Observable.zip(wallet, serverEnvironment)
            .flatMap { [weak self] signedWallet, serverEnvironment -> Observable<DomainLayer.DTO.WEGateway.SendBinding> in
                
                guard let self = self else { return Observable.never() }
                                
                let oauthToken = self.oAuthRepository.oauthToken(serverEnvironment: serverEnvironment,
                                                                 signedWallet: signedWallet)
                
                return oauthToken
                    .flatMap { [weak self] token -> Observable<DomainLayer.DTO.WEGateway.SendBinding> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        return self.gatewayRepository.transferBinding(serverEnvironment: serverEnvironment,
                                                                      request: .init(senderAsset: asset.id,
                                                                                     recipientAsset: asset.gatewayId ?? "",
                                                                                     recipientAddress: address,
                                                                                     token: token))
                            .map { (transferBindig) -> DomainLayer.DTO.WEGateway.SendBinding in
                                                                                                
                                let fee = self.calculateFee(asset: asset,
                                                            amount: amount,
                                                            transferBinding: transferBindig)
                                
                                return DomainLayer.DTO.WEGateway.SendBinding(addresses: transferBindig.addresses,
                                                                             amountMin: Money(transferBindig.amountMin,
                                                                                              asset.precision),
                                                                             amountMax: Money(transferBindig.amountMax,
                                                                                              asset.precision),
                                                                             fee: fee)
                        }
                }
                .catchError { (error) -> Observable<DomainLayer.DTO.WEGateway.SendBinding> in
                    return Observable.error(NetworkError.error(by: error))
                }
        }
    }
    
    private func calculateFee(asset: DomainLayer.DTO.Asset,
                              amount: Money,
                              transferBinding: DomainLayer.DTO.WEGateway.TransferBinding) -> Money {
                        
        let amountDecimal = amount.decimalValue
        let taxFlatDecimal = Money(transferBinding.taxFlat, asset.precision).decimalValue
        
        let amountTotal = (amountDecimal / Decimal(transferBinding.taxRate)).rounded(asset.precision, .up) + taxFlatDecimal
        let fee = amountTotal - amountDecimal

        return Money(value: fee, asset.precision)
    }
}
